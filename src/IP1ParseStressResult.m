#import "IP1ParseStressResult.h"

@implementation IP1ParseStressResult
@synthesize iterationsRequested = _iterationsRequested;
@synthesize iterationsCompleted = _iterationsCompleted;
@synthesize failures = _failures;
@synthesize totalElapsedSeconds = _totalElapsedSeconds;
@synthesize passed = _passed;
@synthesize lastError = _lastError;

- (NSDictionary *)dictionaryRepresentation {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedInteger:_iterationsRequested], @"iterationsRequested",
            [NSNumber numberWithUnsignedInteger:_iterationsCompleted], @"iterationsCompleted",
            [NSNumber numberWithUnsignedInteger:_failures], @"failures",
            [NSNumber numberWithDouble:_totalElapsedSeconds], @"totalElapsedSeconds",
            [NSNumber numberWithBool:_passed], @"passed",
            (_lastError ?: @""), @"lastError",
            nil];
}

- (void)dealloc {
    [_lastError release];
    [super dealloc];
}
@end
