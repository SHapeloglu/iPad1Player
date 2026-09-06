#import <Foundation/Foundation.h>

@class IP1AudioEngine;
@class IP1FFmpegAudioDecoder;
@class IP1FFmpegVideoDecoder;
@class IP1PlaybackClock;
@class IP1PacketQueue;
@class IP1FFmpegAudioSession;

@protocol IP1FFmpegAudioSessionVideoDelegate <NSObject>
@optional
- (void)ffmpegAudioSession:(IP1FFmpegAudioSession *)session
                 didDecodeY:(const uint8_t *)y
                    yStride:(NSInteger)yStride
                          u:(const uint8_t *)u
                    uStride:(NSInteger)uStride
                          v:(const uint8_t *)v
                    vStride:(NSInteger)vStride
                      width:(NSInteger)width
                     height:(NSInteger)height;
@end

@interface IP1FFmpegAudioSession : NSObject {
@private
    IP1AudioEngine *_audioEngine;
    IP1FFmpegAudioDecoder *_decoder;
    IP1FFmpegVideoDecoder *_videoDecoder;
    IP1PlaybackClock *_clock;
    id<IP1FFmpegAudioSessionVideoDelegate> _videoDelegate;
    NSString *_path;
    NSInteger _audioStreamIndex;
    NSInteger _videoStreamIndex;
    NSInteger _decodedVideoFrameCount;
    NSInteger _videoWidth;
    NSInteger _videoHeight;
    BOOL _prepared;
    BOOL _running;
    volatile BOOL _stopRequested;

    /*
     Tek demux reader korunur.
     H.264 decode ayrı worker üzerinde çalışır.
    */
    IP1PacketQueue *_videoPacketQueue;
    volatile BOOL _videoWorkerStopRequested;
    volatile BOOL _videoWorkerRunning;
    volatile BOOL _videoInputEnded;
    NSUInteger _droppedVideoPackets;

    NSTimeInterval _decodedAudioTime;
}
@property(nonatomic, readonly) BOOL prepared;
@property(nonatomic, readonly) BOOL running;
@property(nonatomic, readonly) NSInteger audioStreamIndex;
@property(nonatomic, readonly) NSInteger videoStreamIndex;
@property(nonatomic, readonly) NSInteger decodedVideoFrameCount;
@property(nonatomic, readonly) NSInteger videoWidth;
@property(nonatomic, readonly) NSInteger videoHeight;
@property(nonatomic, readonly) NSTimeInterval decodedAudioTime;
@property(nonatomic, readonly, retain) IP1PlaybackClock *clock;
@property(nonatomic, assign) id<IP1FFmpegAudioSessionVideoDelegate> videoDelegate;

- (BOOL)preparePath:(NSString *)path
   audioStreamIndex:(NSInteger)streamIndex
              error:(NSString **)errorMessage;
- (void)start;
- (void)pause;
- (void)stop;
- (void)handleMemoryWarning;
@end
