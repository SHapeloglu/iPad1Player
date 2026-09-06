#import "IP1SubtitleCue.h"
@implementation IP1SubtitleCue
@synthesize startTime = _startTime;
@synthesize endTime = _endTime;
@synthesize text = _text;
- (void)dealloc { [_text release]; [super dealloc]; }
@end
