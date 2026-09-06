#import "IP1AudioEngine.h"
#import "IP1PCMRingBuffer.h"
#import "IP1AudioRuntimeProfile.h"
#import "IP1AudioQueueOutput.h"

@implementation IP1AudioEngine
@synthesize selectedStreamIndex = _selectedStreamIndex;

- (id)init {
    self = [super init];
    if (self) {
        _pcmBuffer = [[IP1PCMRingBuffer alloc] initWithCapacityBytes:[IP1AudioRuntimeProfile pcmBufferBytes]];
        _output = [[IP1AudioQueueOutput alloc] initWithPCMBuffer:_pcmBuffer];
        _selectedStreamIndex = -1;
        _prepared = NO;
        _playing = NO;
        _clockTime = 0.0;
    }
    return self;
}

- (BOOL)prepared { return _prepared; }
- (BOOL)playing { return _playing; }
- (double)clockTime { return _clockTime; }
- (NSUInteger)pcmUsedBytes { return [_pcmBuffer usedBytes]; }
- (NSUInteger)pcmCapacityBytes { return [_pcmBuffer capacityBytes]; }

- (BOOL)prepareWithError:(NSString **)errorMessage {
    BOOL ok = [_output prepareSampleRate:[IP1AudioRuntimeProfile preferredSampleRate]
                               channels:(UInt32)[IP1AudioRuntimeProfile preferredOutputChannels]
                                  error:errorMessage];
    _prepared = ok;
    return ok;
}

- (void)play {
    if (_prepared) { [_output start]; _playing = [_output running]; }
}

- (void)pause {
    [_output pause];
    _playing = NO;
}

- (void)stop {
    [_output stop];
    _playing = NO;
    _prepared = NO;
    _clockTime = 0.0;
    [_pcmBuffer flush];
}

- (void)flush {
    [_pcmBuffer flush];
    _clockTime = 0.0;
}

- (void)handleMemoryWarning {
    /* PCM buffer is already capped at 256 KB; flush stale decoded audio. */
    [_pcmBuffer flush];
}


- (NSUInteger)enqueuePCMBytes:(const void *)bytes length:(NSUInteger)length {
    return [_pcmBuffer writeBytes:bytes length:length];
}


- (void)setClockTime:(double)clockTime {
    _clockTime = (clockTime >= 0.0 ? clockTime : 0.0);
}

- (void)dealloc {
    [_output release];
    [_pcmBuffer release];
    [super dealloc];
}
@end
