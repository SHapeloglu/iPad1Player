#import "IP1FFmpegVideoDecoder.h"

#ifdef IP1_FFMPEG_BACKEND
#include <errno.h>
#endif

@implementation IP1FFmpegVideoDecoder

- (id)init {
    self = [super init];
    if (self) {
#ifdef IP1_FFMPEG_BACKEND
        _codecContext = NULL;
        _frame = NULL;
        _lastFrame = NULL;
#endif
        _opened = NO;
        _decodedFrameCount = 0;
        _width = 0;
        _height = 0;
    }
    return self;
}

- (BOOL)opened { return _opened; }
- (NSInteger)decodedFrameCount { return _decodedFrameCount; }
- (NSInteger)width { return _width; }
- (NSInteger)height { return _height; }

#ifdef IP1_FFMPEG_BACKEND

- (BOOL)openStream:(AVStream *)stream error:(NSString **)errorMessage {
    [self close];

    if (!stream) {
        if (errorMessage) *errorMessage = @"Video stream boş.";
        return NO;
    }

    if (IP1FFStreamCodecID(stream) != AV_CODEC_ID_H264) {
        if (errorMessage) *errorMessage = @"Video codec H.264 değil.";
        return NO;
    }

    AVCodec *codec = avcodec_find_decoder(AV_CODEC_ID_H264);
    if (!codec) {
        if (errorMessage) *errorMessage = @"FFmpeg H.264 decoder bulunamadı.";
        return NO;
    }

    _codecContext = avcodec_alloc_context3(codec);
    if (!_codecContext ||
        avcodec_parameters_to_context(_codecContext, stream->codecpar) < 0) {
        if (errorMessage) *errorMessage = @"H.264 codec context hazırlanamadı.";
        [self close];
        return NO;
    }

    /*
     iPad 1: decoder thread sayısını düşük tut.
     İlk gerçek cihaz testi için tek thread.
    */
    _codecContext->thread_count = 1;

    if (avcodec_open2(_codecContext, codec, NULL) < 0) {
        if (errorMessage) *errorMessage = @"H.264 decoder açılamadı.";
        [self close];
        return NO;
    }

    _frame = av_frame_alloc();
    _lastFrame = av_frame_alloc();

    if (!_frame || !_lastFrame) {
        if (errorMessage) *errorMessage = @"H.264 frame ayrılamadı.";
        [self close];
        return NO;
    }

    _width = _codecContext->width;
    _height = _codecContext->height;
    _decodedFrameCount = 0;
    _opened = YES;

    return YES;
}

- (NSInteger)decodePacket:(AVPacket *)packet error:(NSString **)errorMessage {
    if (!_opened || !_codecContext || !_frame || !packet) return 0;

    int rc = avcodec_send_packet(_codecContext, packet);
    if (rc < 0) {
        if (errorMessage) *errorMessage = @"H.264 packet decoder'a verilemedi.";
        return -1;
    }

    NSInteger frames = 0;

    while (1) {
        rc = avcodec_receive_frame(_codecContext, _frame);

        if (rc == AVERROR(EAGAIN) || rc == AVERROR_EOF) {
            break;
        }

        if (rc < 0) {
            if (errorMessage) *errorMessage = @"H.264 frame decode hatası.";
            return -1;
        }

        _width = _frame->width;
        _height = _frame->height;

        /*
         avcodec_receive_frame() bir sonraki çağrıda _frame'i
         yeniden kullanabilir/unref edebilir.

         Bu nedenle son başarılı decoded frame'i ayrı bir AVFrame
         referansı olarak sakla. AudioSession decodePacket döndükten
         sonra YUV plane'lerini buradan okuyacak.
        */
        av_frame_unref(_lastFrame);

        if (av_frame_ref(_lastFrame, _frame) < 0) {
            if (errorMessage)
                *errorMessage = @"H.264 son frame referansı alınamadı.";
            return -1;
        }

        _decodedFrameCount++;
        frames++;
    }

    return frames;
}

- (BOOL)currentYUV420PWithY:(const uint8_t **)y
                    yStride:(NSInteger *)yStride
                          u:(const uint8_t **)u
                    uStride:(NSInteger *)uStride
                          v:(const uint8_t **)v
                    vStride:(NSInteger *)vStride
                      width:(NSInteger *)width
                     height:(NSInteger *)height {

    if (!_opened || !_lastFrame) return NO;

    if (_lastFrame->format != AV_PIX_FMT_YUV420P) return NO;

    if (!_lastFrame->data[0] ||
        !_lastFrame->data[1] ||
        !_lastFrame->data[2]) {
        return NO;
    }

    if (y) *y = _lastFrame->data[0];
    if (u) *u = _lastFrame->data[1];
    if (v) *v = _lastFrame->data[2];

    if (yStride) *yStride = _lastFrame->linesize[0];
    if (uStride) *uStride = _lastFrame->linesize[1];
    if (vStride) *vStride = _lastFrame->linesize[2];

    if (width) *width = _lastFrame->width;
    if (height) *height = _lastFrame->height;

    return YES;
}

#endif

- (void)close {
#ifdef IP1_FFMPEG_BACKEND
    if (_frame) {
        av_frame_free(&_frame);
        _frame = NULL;
    }

    if (_lastFrame) {
        av_frame_free(&_lastFrame);
        _lastFrame = NULL;
    }

    if (_codecContext) {
        avcodec_free_context(&_codecContext);
    }
#endif

    _opened = NO;
}

- (void)dealloc {
    [self close];
    [super dealloc];
}

@end
