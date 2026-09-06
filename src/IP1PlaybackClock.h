#import <Foundation/Foundation.h>

typedef enum {
    IP1ClockMasterAudio = 0,
    IP1ClockMasterVideo,
    IP1ClockMasterExternal
} IP1ClockMaster;

@interface IP1PlaybackClock : NSObject {
@private
    IP1ClockMaster _master;
    NSTimeInterval _audioTime;
    NSTimeInterval _videoTime;
    NSTimeInterval _externalTime;
}
@property(nonatomic, assign) IP1ClockMaster master;
@property(nonatomic, assign) NSTimeInterval audioTime;
@property(nonatomic, assign) NSTimeInterval videoTime;
@property(nonatomic, assign) NSTimeInterval externalTime;
- (NSTimeInterval)masterTime;
- (void)resetToTime:(NSTimeInterval)time;
@end
