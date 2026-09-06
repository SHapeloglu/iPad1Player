#import "IP1FFmpegAudioDecoder.h"
#import "IP1AudioRuntimeProfile.h"

#ifdef IP1_FFMPEG_BACKEND
#include <libswresample/swresample.h>
#include <libavutil/channel_layout.h>
#include <libavutil/samplefmt.h>
#endif

@implementation IP1FFmpegAudioDecoder
@synthesize streamIndex = _streamIndex;

- (id)init {
    self = [super init];
    if (self) {
        _streamIndex = -1;
        _opened = NO;
#ifdef IP1_FFMPEG_BACKEND
        _codecContext = NULL;
        _frame = NULL;
        _swrContext = NULL;
#endif
    }
    return self;
}

- (BOOL)opened { return _opened; }

#ifdef IP1_FFMPEG_BACKEND
- (BOOL)openStream:(AVStream *)stream error:(NSString **)errorMessage {
    [self close];
    if (!stream) {
        if (errorMessage) *errorMessage = @"Audio stream boş.";
        return NO;
    }

    enum AVCodecID codecID = IP1FFStreamCodecID(stream);
    if (codecID != AV_CODEC_ID_AAC && codecID != AV_CODEC_ID_MP3) {
        if (errorMessage) *errorMessage = @"Alpha17 yalnız AAC/MP3 decode eder.";
        return NO;
    }

    AVCodec *codec = avcodec_find_decoder(codecID);
    if (!codec) {
        if (errorMessage) *errorMessage = @"FFmpeg audio decoder bulunamadı.";
        return NO;
    }

#if LIBAVCODEC_VERSION_MAJOR >= 57
    _codecContext = avcodec_alloc_context3(codec);
    if (!_codecContext || avcodec_parameters_to_context(_codecContext, stream->codecpar) < 0) {
        if (errorMessage) *errorMessage = @"Audio codec context hazırlanamadı.";
        [self close];
        return NO;
    }
#else
    _codecContext = stream->codec;
#endif

    if (avcodec_open2(_codecContext, codec, NULL) < 0) {
        if (errorMessage) *errorMessage = @"AAC/MP3 decoder açılamadı.";
        [self close];
        return NO;
    }

    _frame = av_frame_alloc();
    if (!_frame) {
        if (errorMessage) *errorMessage = @"Audio frame ayrılamadı.";
        [self close];
        return NO;
    }

    _opened = YES;
    return YES;
}

- (NSInteger)decodePacket:(AVPacket *)packet
                 pcmS16LE:(void *)output
                 maxBytes:(NSUInteger)maxBytes
                    error:(NSString **)errorMessage {
    if (!_opened || !_codecContext || !_frame || !packet || !output || maxBytes == 0) return 0;

#if LIBAVCODEC_VERSION_MAJOR >= 57
    int rc = avcodec_send_packet(_codecContext, packet);
    if (rc < 0) {
        if (errorMessage) *errorMessage = @"Audio packet decoder'a verilemedi.";
        return -1;
    }
    rc = avcodec_receive_frame(_codecContext, _frame);
    if (rc < 0) return 0;
#else
    int gotFrame = 0;
    int rc = avcodec_decode_audio4(_codecContext, _frame, &gotFrame, packet);
    if (rc < 0) {
        if (errorMessage) *errorMessage = @"Legacy audio decode hatası.";
        return -1;
    }
    if (!gotFrame) return 0;
#endif

    /*
     iPad 1 audio runtime contract:
       input  : decoder native format (FLTP/S16P/S16/...)
       output : 44.1 kHz, stereo, packed signed 16-bit PCM

     AudioQueue is configured by IP1AudioRuntimeProfile with exactly
     this format, therefore every decoded frame passes through swresample.
    */

    int inputRate = _frame->sample_rate;
    if (inputRate <= 0) inputRate = _codecContext->sample_rate;
    if (inputRate <= 0) {
        if (errorMessage) *errorMessage = @"Audio sample rate geçersiz.";
        return -1;
    }

    int inputChannels = _frame->channels;
    if (inputChannels <= 0) inputChannels = IP1FFCodecContextChannels(_codecContext);
    if (inputChannels <= 0) inputChannels = 2;

    int64_t inputLayout = _frame->channel_layout;
    if (!inputLayout) inputLayout = _codecContext->channel_layout;
    if (!inputLayout) inputLayout = av_get_default_channel_layout(inputChannels);

    enum AVSampleFormat inputFormat = (enum AVSampleFormat)_frame->format;
    if (inputFormat == AV_SAMPLE_FMT_NONE) {
        if (errorMessage) *errorMessage = @"Audio sample formatı geçersiz.";
        return -1;
    }

    const int outputRate = (int)[IP1AudioRuntimeProfile preferredSampleRate];
    const int outputChannels = (int)[IP1AudioRuntimeProfile preferredOutputChannels];
    const int64_t outputLayout =
        (outputChannels == 1 ? AV_CH_LAYOUT_MONO : AV_CH_LAYOUT_STEREO);

    /*
     iPad 1 optimizasyonu:
     SwrContext pahalıdır. Her AAC frame'inde yeniden alloc/init etme.

     Format aynı kaldığı sürece mevcut context'i koru.
     Kaynak format/sample-rate/channel-layout veya çıkış profili
     gerçekten değişirse yeniden oluştur.
    */
    BOOL swrNeedsRebuild =
        (!_swrContext ||
         _swrInputLayout != inputLayout ||
         _swrInputFormat != (int)inputFormat ||
         _swrInputRate != inputRate ||
         _swrOutputLayout != outputLayout ||
         _swrOutputRate != outputRate ||
         _swrOutputChannels != outputChannels);

    if (swrNeedsRebuild) {

        if (_swrContext) {
            swr_free(&_swrContext);
        }

        _swrContext = swr_alloc_set_opts(NULL,
                                        outputLayout,
                                        AV_SAMPLE_FMT_S16,
                                        outputRate,
                                        inputLayout,
                                        inputFormat,
                                        inputRate,
                                        0,
                                        NULL);

        if (!_swrContext || swr_init(_swrContext) < 0) {
            if (errorMessage)
                *errorMessage = @"swresample başlatılamadı.";

            if (_swrContext)
                swr_free(&_swrContext);

            return -1;
        }

        _swrInputLayout = inputLayout;
        _swrInputFormat = (int)inputFormat;
        _swrInputRate = inputRate;

        _swrOutputLayout = outputLayout;
        _swrOutputRate = outputRate;
        _swrOutputChannels = outputChannels;
    }

    const NSUInteger bytesPerOutputFrame =
        (NSUInteger)outputChannels * sizeof(int16_t);

    int maxOutputSamples =
        (int)(maxBytes / bytesPerOutputFrame);

    if (maxOutputSamples <= 0) {
        if (errorMessage) *errorMessage = @"PCM çıkış bufferı yetersiz.";
        return -1;
    }

    uint8_t *outputPlanes[1];
    outputPlanes[0] = (uint8_t *)output;

    const uint8_t **inputPlanes =
        (const uint8_t **)_frame->extended_data;

    int convertedSamples =
        swr_convert(_swrContext,
                    outputPlanes,
                    maxOutputSamples,
                    inputPlanes,
                    _frame->nb_samples);

    if (convertedSamples < 0) {
        if (errorMessage) *errorMessage = @"Audio swresample dönüşümü başarısız.";
        return -1;
    }

    NSUInteger bytes =
        (NSUInteger)convertedSamples * bytesPerOutputFrame;

    if (bytes > maxBytes) bytes = maxBytes;

    return (NSInteger)bytes;
}
#endif

- (void)close {
#ifdef IP1_FFMPEG_BACKEND
    if (_swrContext) {
        swr_free(&_swrContext);
        _swrContext = NULL;
    }

    if (_frame) {
        av_frame_free(&_frame);
        _frame = NULL;
    }

#if LIBAVCODEC_VERSION_MAJOR >= 57
    if (_codecContext) {
        avcodec_free_context(&_codecContext);
    }
#else
    if (_codecContext) {
        avcodec_close(_codecContext);
        _codecContext = NULL;
    }
#endif
#endif
    _opened = NO;
    _streamIndex = -1;
}

- (void)dealloc {
    [self close];
    [super dealloc];
}
@end
