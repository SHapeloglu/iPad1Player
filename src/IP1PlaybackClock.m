#import "IP1PlaybackClock.h"

@implementation IP1PlaybackClock
@synthesize master = _master;
@synthesize audioTime = _audioTime;
@synthesize videoTime = _videoTime;
@synthesize externalTime = _externalTime;

- (id)init {
    self = [super init];
    if (self) {
        _master = IP1ClockMasterAudio;
        _audioTime = 0.0;
        _videoTime = 0.0;
        _externalTime = 0.0;
    }
    return self;
}

- (NSTimeInterval)masterTime {
    switch (_master) {
        case IP1ClockMasterVideo: return _videoTime;
        case IP1ClockMasterExternal: return _externalTime;
        default: return _audioTime;
    }
}

- (void)resetToTime:(NSTimeInterval)time {
    _audioTime = time;
    _videoTime = time;
    _externalTime = time;
}
@end
