#import "IP1VideoDecodeCapability.h"

@implementation IP1VideoDecodeCapability
@synthesize codec = _codec;
@synthesize width = _width;
@synthesize height = _height;
@synthesize decision = _decision;
@synthesize reason = _reason;

- (NSDictionary *)dictionaryRepresentation {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            (_codec ?: @""), @"codec",
            [NSNumber numberWithInteger:_width], @"width",
            [NSNumber numberWithInteger:_height], @"height",
            [NSNumber numberWithInteger:_decision], @"decision",
            (_reason ?: @""), @"reason",
            nil];
}

- (void)dealloc {
    [_codec release];
    [_reason release];
    [super dealloc];
}
@end
