#import <Foundation/Foundation.h>
@class IP1PCMRingBuffer;
@class IP1AudioQueueOutput;

@interface IP1AudioEngine : NSObject {
@private
    IP1PCMRingBuffer *_pcmBuffer;
    IP1AudioQueueOutput *_output;
    BOOL _prepared;
    BOOL _playing;
    NSInteger _selectedStreamIndex;
    double _clockTime;
}
@property(nonatomic, readonly) BOOL prepared;
@property(nonatomic, readonly) BOOL playing;
@property(nonatomic, assign) NSInteger selectedStreamIndex;
@property(nonatomic, readonly) double clockTime;
@property(nonatomic, readonly) NSUInteger pcmUsedBytes;
@property(nonatomic, readonly) NSUInteger pcmCapacityBytes;

- (BOOL)prepareWithError:(NSString **)errorMessage;
- (void)play;
- (void)pause;
- (void)stop;
- (void)flush;
- (void)handleMemoryWarning;
- (NSUInteger)enqueuePCMBytes:(const void *)bytes length:(NSUInteger)length;
- (void)setClockTime:(double)clockTime;
@end
