#import "IP1MediaTrack.h"

@implementation IP1MediaTrack
@synthesize streamIndex = _streamIndex;
@synthesize type = _type;
@synthesize codecName = _codecName;
@synthesize language = _language;
@synthesize title = _title;
@synthesize selected = _selected;

- (void)dealloc {
    [_codecName release];
    [_language release];
    [_title release];
    [super dealloc];
}
@end
