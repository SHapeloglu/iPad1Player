#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
@class IP1PCMRingBuffer;

@interface IP1AudioQueueOutput : NSObject {
@private
    AudioQueueRef _queue;
    AudioQueueBufferRef _buffers[3];
    AudioStreamBasicDescription _format;
    IP1PCMRingBuffer *_pcmBuffer;
    BOOL _running;
}
@property(nonatomic, readonly) BOOL running;

- (id)initWithPCMBuffer:(IP1PCMRingBuffer *)pcmBuffer;
- (BOOL)prepareSampleRate:(Float64)sampleRate channels:(UInt32)channels error:(NSString **)errorMessage;
- (void)start;
- (void)pause;
- (void)stop;
- (void)disposeQueue;
@end
