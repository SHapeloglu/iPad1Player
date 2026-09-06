#import "IP1ParseDiagnostics.h"

@implementation IP1ParseDiagnostics
@synthesize elapsedSeconds = _elapsedSeconds;
@synthesize trackCount = _trackCount;
@synthesize chapterCount = _chapterCount;
@synthesize withinLimits = _withinLimits;
@synthesize message = _message;

- (NSDictionary *)dictionaryRepresentation {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithDouble:_elapsedSeconds], @"elapsedSeconds",
            [NSNumber numberWithUnsignedInteger:_trackCount], @"trackCount",
            [NSNumber numberWithUnsignedInteger:_chapterCount], @"chapterCount",
            [NSNumber numberWithBool:_withinLimits], @"withinLimits",
            (_message ?: @""), @"message",
            nil];
}

- (void)dealloc {
    [_message release];
    [super dealloc];
}
@end
