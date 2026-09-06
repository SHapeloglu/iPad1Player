#import "IP1DeviceTestStatus.h"

@implementation IP1DeviceTestRecord
@synthesize feature = _feature;
@synthesize status = _status;
@synthesize notes = _notes;

- (void)dealloc {
    [_feature release];
    [_notes release];
    [super dealloc];
}
@end
