#import "IP1FFmpegAudioSession.h"
#import "IP1AudioEngine.h"
#import "IP1AudioRuntimeProfile.h"
#import "IP1FFmpegAudioDecoder.h"
#import "IP1FFmpegVideoDecoder.h"
#import "IP1H264DecodePolicy.h"
#import "IP1PlaybackClock.h"
#import "IP1FFmpegCompat.h"
#import "IP1PacketQueue.h"

/*
 Compressed AVPacket için Objective-C/MRC sahiplik wrapper'ı.

 av_read_frame() tarafından verilen packet demux thread'in sonunda
 unref ediliyor. Worker'a gönderirken av_packet_ref ile bağımsız
 referans almak zorundayız.
*/
@interface IP1OwnedVideoPacket : NSObject {
@private
#ifdef IP1_FFMPEG_BACKEND
    AVPacket _packet;
#endif
}

#ifdef IP1_FFMPEG_BACKEND
- (id)initWithPacket:(AVPacket *)packet;
- (AVPacket *)packet;
- (NSUInteger)estimatedBytes;
#endif

@end

@implementation IP1OwnedVideoPacket

#ifdef IP1_FFMPEG_BACKEND

- (id)initWithPacket:(AVPacket *)packet
{
    self = [super init];

    if (self) {
        memset(&_packet, 0, sizeof(_packet));

        if (!packet || av_packet_ref(&_packet, packet) < 0) {
            [self release];
            return nil;
        }
    }

    return self;
}

- (AVPacket *)packet
{
    return &_packet;
}

- (NSUInteger)estimatedBytes
{
    return (_packet.size > 0 ?
            (NSUInteger)_packet.size :
            (NSUInteger)1);
}

#endif

- (void)dealloc
{
#ifdef IP1_FFMPEG_BACKEND
    IP1FFPacketUnref(&_packet);
#endif
    [super dealloc];
}

@end


@implementation IP1FFmpegAudioSession

@synthesize videoDelegate = _videoDelegate;

- (id)init {
    self = [super init];
    if (self) {
        _audioEngine = [[IP1AudioEngine alloc] init];
        _decoder = [[IP1FFmpegAudioDecoder alloc] init];
        _videoDecoder = [[IP1FFmpegVideoDecoder alloc] init];
        _clock = [[IP1PlaybackClock alloc] init];
        _clock.master = IP1ClockMasterAudio;
        _audioStreamIndex = -1;
        _videoStreamIndex = -1;
        _decodedVideoFrameCount = 0;
        _videoWidth = 0;
        _videoHeight = 0;
        _prepared = NO;
        _running = NO;
        _stopRequested = NO;

        _videoPacketQueue = nil;
        _videoWorkerStopRequested = NO;
        _videoWorkerRunning = NO;
        _videoInputEnded = NO;
        _droppedVideoPackets = 0;

        _decodedAudioTime = 0.0;
    }
    return self;
}

- (BOOL)prepared { return _prepared; }
- (BOOL)running { return _running; }
- (NSInteger)audioStreamIndex { return _audioStreamIndex; }
- (NSInteger)videoStreamIndex { return _videoStreamIndex; }
- (NSInteger)decodedVideoFrameCount { return _decodedVideoFrameCount; }
- (NSInteger)videoWidth { return _videoWidth; }
- (NSInteger)videoHeight { return _videoHeight; }
- (NSTimeInterval)decodedAudioTime { return _decodedAudioTime; }
- (IP1PlaybackClock *)clock { return _clock; }

- (BOOL)preparePath:(NSString *)path
   audioStreamIndex:(NSInteger)streamIndex
              error:(NSString **)errorMessage {
#ifndef IP1_FFMPEG_BACKEND
    if (errorMessage) *errorMessage = @"FFmpeg audio runtime bu derlemede etkin değil.";
    return NO;
#else
    [self stop];

    if (![path length]) {
        if (errorMessage) *errorMessage = @"Audio runtime medya yolu boş.";
        return NO;
    }

    AVFormatContext *formatContext = NULL;
    if (avformat_open_input(&formatContext, [path fileSystemRepresentation], NULL, NULL) < 0 || !formatContext) {
        if (errorMessage) *errorMessage = @"Audio runtime containerı açamadı.";
        if (formatContext) avformat_close_input(&formatContext);
        return NO;
    }

    if (avformat_find_stream_info(formatContext, NULL) < 0) {
        if (errorMessage) *errorMessage = @"Audio runtime stream bilgisini okuyamadı.";
        avformat_close_input(&formatContext);
        return NO;
    }

    NSInteger selected = streamIndex;
    if (selected < 0) {
        unsigned int i;
        selected = -1;
        for (i = 0; i < formatContext->nb_streams; i++) {
            AVStream *stream = formatContext->streams[i];
            if (IP1FFStreamType(stream) != AVMEDIA_TYPE_AUDIO) continue;
            enum AVCodecID codecID = IP1FFStreamCodecID(stream);
            if (codecID == AV_CODEC_ID_AAC || codecID == AV_CODEC_ID_MP3) {
                selected = (NSInteger)i;
                break;
            }
        }
    }

    if (selected < 0 || selected >= (NSInteger)formatContext->nb_streams) {
        if (errorMessage) *errorMessage = @"AAC/MP3 audio stream bulunamadı.";
        avformat_close_input(&formatContext);
        return NO;
    }

    NSInteger selectedVideo = -1;
    NSInteger selectedVideoWidth = 0;
    NSInteger selectedVideoHeight = 0;

    unsigned int videoSearchIndex;
    for (videoSearchIndex = 0;
         videoSearchIndex < formatContext->nb_streams;
         videoSearchIndex++) {

        AVStream *candidate = formatContext->streams[videoSearchIndex];

        if (IP1FFStreamType(candidate) != AVMEDIA_TYPE_VIDEO) continue;
        if (IP1FFStreamCodecID(candidate) != AV_CODEC_ID_H264) continue;

        NSInteger width = IP1FFStreamWidth(candidate);
        NSInteger height = IP1FFStreamHeight(candidate);

        if ([IP1H264DecodePolicy isSoftwareTargetWidth:width height:height]) {
            selectedVideo = (NSInteger)videoSearchIndex;
            selectedVideoWidth = width;
            selectedVideoHeight = height;
            break;
        }
    }

    AVStream *audioStream = formatContext->streams[selected];
    if (IP1FFStreamType(audioStream) != AVMEDIA_TYPE_AUDIO) {
        if (errorMessage) *errorMessage = @"Seçilen stream audio değil.";
        avformat_close_input(&formatContext);
        return NO;
    }

    NSString *decodeError = nil;
    if (![_decoder openStream:audioStream error:&decodeError]) {
        if (errorMessage) *errorMessage = decodeError;
        avformat_close_input(&formatContext);
        return NO;
    }

    NSString *outputError = nil;
    if (![_audioEngine prepareWithError:&outputError]) {
        if (errorMessage) *errorMessage = outputError;
        [_decoder close];
        avformat_close_input(&formatContext);
        return NO;
    }

    /*
     Alpha18 reopens the format context inside the demux thread instead of
     retaining it here. This keeps prepare lightweight and avoids an idle
     FFmpeg context consuming memory while paused before first start.
    */
    [_path release];
    _path = [path copy];
    _audioStreamIndex = selected;
    _videoStreamIndex = selectedVideo;
    _decodedVideoFrameCount = 0;
    _videoWidth = selectedVideoWidth;
    _videoHeight = selectedVideoHeight;
    _prepared = YES;
    _stopRequested = NO;
    _decodedAudioTime = 0.0;
    [_clock resetToTime:0.0];

    [_decoder close];
    [_videoDecoder close];
    avformat_close_input(&formatContext);
    return YES;
#endif
}

- (void)start {
    if (!_prepared || _running) return;

    _stopRequested = NO;
    _videoWorkerStopRequested = NO;
    _videoInputEnded = NO;
    _droppedVideoPackets = 0;

    _running = YES;
    [_audioEngine play];
    [NSThread detachNewThreadSelector:@selector(demuxThreadMain) toTarget:self withObject:nil];
}

- (void)pause {
    if (!_running) return;

    _stopRequested = YES;
    _videoWorkerStopRequested = YES;

    if (_videoPacketQueue)
        [_videoPacketQueue flush];

    [_audioEngine pause];
    _running = NO;
}

- (void)stop {
    _stopRequested = YES;
    _videoWorkerStopRequested = YES;

    if (_videoPacketQueue)
        [_videoPacketQueue flush];

    /*
     Worker'ın _videoDecoder kullanmayı bırakması için kısa süre bekle.
     iPad 1'de decoder'ı worker çalışırken kapatmak crash/race yaratır.
    */
    NSInteger waitCount = 0;

    while (_videoWorkerRunning && waitCount < 100) {
        [NSThread sleepForTimeInterval:0.005];
        waitCount++;
    }

    _running = NO;
    _prepared = NO;
    _audioStreamIndex = -1;
    _videoStreamIndex = -1;
    _decodedVideoFrameCount = 0;
    _videoWidth = 0;
    _videoHeight = 0;
    _decodedAudioTime = 0.0;
    [_clock resetToTime:0.0];
    [_decoder close];

    /*
     Normalde video worker decoder'ı kendisi kapatır.
     Worker artık çalışmıyorsa burada güvenle kapatabiliriz.
    */
    if (!_videoWorkerRunning)
        [_videoDecoder close];

    [_videoPacketQueue release];
    _videoPacketQueue = nil;

    _videoInputEnded = NO;

    [_audioEngine stop];
    [_path release];
    _path = nil;
}

- (void)handleMemoryWarning {
    [_audioEngine handleMemoryWarning];
}

- (void)videoDecodeThreadMain
{
    NSAutoreleasePool *outerPool =
        [[NSAutoreleasePool alloc] init];

#ifdef IP1_FFMPEG_BACKEND

    _videoWorkerRunning = YES;

    while (!_videoWorkerStopRequested) {

        NSAutoreleasePool *iterationPool =
            [[NSAutoreleasePool alloc] init];

        IP1OwnedVideoPacket *ownedPacket =
            [_videoPacketQueue dequeueObject];

        if (!ownedPacket) {

            BOOL inputEnded =
                _videoInputEnded;

            NSUInteger queueCount =
                (_videoPacketQueue ?
                 [_videoPacketQueue count] :
                 0);

            [iterationPool drain];

            if (inputEnded && queueCount == 0)
                break;

            [NSThread sleepForTimeInterval:0.003];
            continue;
        }

        NSString *videoDecodeError = nil;

        NSInteger videoFrames =
            [_videoDecoder decodePacket:[ownedPacket packet]
                                  error:&videoDecodeError];

        if (videoFrames > 0) {

            _decodedVideoFrameCount += videoFrames;
            _videoWidth = [_videoDecoder width];
            _videoHeight = [_videoDecoder height];

            const uint8_t *y = NULL;
            const uint8_t *u = NULL;
            const uint8_t *v = NULL;

            NSInteger yStride = 0;
            NSInteger uStride = 0;
            NSInteger vStride = 0;

            NSInteger width = 0;
            NSInteger height = 0;

            if ([_videoDecoder currentYUV420PWithY:&y
                                           yStride:&yStride
                                                 u:&u
                                           uStride:&uStride
                                                 v:&v
                                           vStride:&vStride
                                             width:&width
                                            height:&height]) {

                id<IP1FFmpegAudioSessionVideoDelegate> delegate =
                    _videoDelegate;

                if (delegate &&
                    [delegate respondsToSelector:
                        @selector(ffmpegAudioSession:didDecodeY:yStride:u:uStride:v:vStride:width:height:)]) {

                    [delegate ffmpegAudioSession:self
                                     didDecodeY:y
                                        yStride:yStride
                                              u:u
                                        uStride:uStride
                                              v:v
                                        vStride:vStride
                                          width:width
                                         height:height];
                }
            }
        }

        [iterationPool drain];
    }

    [_videoDecoder close];

    _videoWorkerRunning = NO;

#endif

    [outerPool drain];
}

- (void)demuxThreadMain {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#ifdef IP1_FFMPEG_BACKEND
    AVFormatContext *formatContext = NULL;
    AVPacket packet;
    memset(&packet, 0, sizeof(packet));

    if (avformat_open_input(&formatContext, [_path fileSystemRepresentation], NULL, NULL) < 0 || !formatContext) {
        _running = NO;
        [pool drain];
        return;
    }

    if (avformat_find_stream_info(formatContext, NULL) < 0 ||
        _audioStreamIndex < 0 ||
        _audioStreamIndex >= (NSInteger)formatContext->nb_streams) {
        avformat_close_input(&formatContext);
        _running = NO;
        [pool drain];
        return;
    }

    AVStream *audioStream = formatContext->streams[_audioStreamIndex];
    NSString *decodeError = nil;
    if (![_decoder openStream:audioStream error:&decodeError]) {
        avformat_close_input(&formatContext);
        _running = NO;
        [pool drain];
        return;
    }

    if (_videoStreamIndex >= 0 &&
        _videoStreamIndex < (NSInteger)formatContext->nb_streams) {

        AVStream *videoStream = formatContext->streams[_videoStreamIndex];
        NSString *videoError = nil;

        if (![_videoDecoder openStream:videoStream error:&videoError]) {
            _videoStreamIndex = -1;
        } else {

            /*
             6 compressed packet:
             iPad 1 için küçük ama decode jitter'ını absorbe edecek
             bounded queue.

             2 MB byte sınırı da bozuk/anormal packet büyümesine karşı
             ikinci güvenlik sınırıdır.
            */
            [_videoPacketQueue release];

            _videoPacketQueue =
                [[IP1PacketQueue alloc]
                    initWithMaxItems:32
                           maxBytes:(4 * 1024 * 1024)];

            _videoWorkerStopRequested = NO;
            _videoInputEnded = NO;
            _videoWorkerRunning = YES;

            [NSThread detachNewThreadSelector:
                @selector(videoDecodeThreadMain)
                                     toTarget:self
                                   withObject:nil];
        }
    }

    const NSUInteger scratchBytes = 64 * 1024;
    void *scratch = malloc(scratchBytes);
    if (!scratch) {
        [_decoder close];
        avformat_close_input(&formatContext);
        _running = NO;
        [pool drain];
        return;
    }

    /*
     Decoder output is normalized by swresample to the exact
     AudioQueue format. Clock calculations therefore use OUTPUT
     format, not the source stream format.
    */
    double sampleRate = [IP1AudioRuntimeProfile preferredSampleRate];
    NSUInteger channels = [IP1AudioRuntimeProfile preferredOutputChannels];

    while (!_stopRequested && av_read_frame(formatContext, &packet) >= 0) {
        if (packet.stream_index == _videoStreamIndex &&
            _videoStreamIndex >= 0 &&
            _videoPacketQueue) {

            IP1OwnedVideoPacket *ownedPacket =
                [[[IP1OwnedVideoPacket alloc]
                    initWithPacket:&packet] autorelease];

            if (ownedPacket) {

                NSUInteger packetBytes =
                    [ownedPacket estimatedBytes];

                /*
                 Kritik kural:
                 VIDEO queue yüzünden demux/audio thread'i BLOKLANMAZ.

                 Queue doluysa bu video packet bırakılır.
                 Normal testte dropped count'un mümkün olduğunca 0
                 kalmasını bekliyoruz.
                */
                BOOL queued = NO;

                while (!_stopRequested &&
                       !_videoWorkerStopRequested &&
                       !queued) {

                    queued =
                        [_videoPacketQueue
                            enqueueObject:ownedPacket
                          estimatedBytes:packetBytes];

                    if (!queued) {
                        /*
                         H.264 compressed packet'i rastgele atmak
                         reference-frame zincirini bozabilir.

                         Worker'a çok kısa süre nefes ver.
                         32 paketlik queue normal decode jitter'ını
                         zaten absorbe eder.
                        */
                        [NSThread sleepForTimeInterval:0.001];
                    }
                }

                if (!queued) {
                    _droppedVideoPackets++;
                }
            }
        }

        if (packet.stream_index == _audioStreamIndex) {
            /*
             Never allow decoded audio to grow without bound. If the PCM ring
             is nearly full, briefly yield instead of decoding more packets.
            */
            while (!_stopRequested &&
                   [_audioEngine pcmUsedBytes] > ([_audioEngine pcmCapacityBytes] * 3 / 4)) {
                [NSThread sleepForTimeInterval:0.01];
            }

            NSString *error = nil;
            NSInteger decoded = [_decoder decodePacket:&packet
                                              pcmS16LE:scratch
                                              maxBytes:scratchBytes
                                                 error:&error];
            if (decoded > 0) {
                NSUInteger written = [_audioEngine enqueuePCMBytes:scratch length:(NSUInteger)decoded];
                if (written > 0 && sampleRate > 0.0 && channels > 0) {
                    _decodedAudioTime += ((double)written / (sampleRate * (double)channels * 2.0));
                    [_audioEngine setClockTime:_decodedAudioTime];
                    _clock.audioTime = _decodedAudioTime;
                }
            } else if (decoded < 0) {
                _stopRequested = YES;
            }
        }

        IP1FFPacketUnref(&packet);
    }

    IP1FFPacketUnref(&packet);

    /*
     Artık yeni compressed video packet gelmeyecek.
     Worker mevcut bounded queue'yu tüketip doğal olarak çıkabilir.
    */
    _videoInputEnded = YES;

    /*
     EOF'ta worker'a queue'yu tüketmesi için kısa bir pencere ver.
     Stop/pause durumunda bekleme yapma.
    */
    if (!_stopRequested) {
        NSInteger videoDrainWait = 0;

        while (_videoWorkerRunning &&
               videoDrainWait < 200) {

            [NSThread sleepForTimeInterval:0.005];
            videoDrainWait++;
        }
    }

    free(scratch);
    [_decoder close];
    avformat_close_input(&formatContext);
#endif
    [_audioEngine pause];
    _running = NO;
    [pool drain];
}

- (void)dealloc {
    [self stop];
    [_audioEngine release];
    [_decoder release];
    [_videoDecoder release];

    [_videoPacketQueue release];
    _videoPacketQueue = nil;

    [_clock release];
    [super dealloc];
}
@end
