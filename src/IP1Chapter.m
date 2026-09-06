#import "IP1Chapter.h"

@implementation IP1Chapter
@synthesize startTime = _startTime;
@synthesize title = _title;

- (void)dealloc {
    [_title release];
    [super dealloc];
}
@end
