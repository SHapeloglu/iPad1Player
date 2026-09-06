#import <Foundation/Foundation.h>

typedef enum {
    IP1DeviceTestUnknown = 0,
    IP1DeviceTestPassed,
    IP1DeviceTestFailed
} IP1DeviceTestStatus;

@interface IP1DeviceTestRecord : NSObject {
@private
    NSString *_feature;
    IP1DeviceTestStatus _status;
    NSString *_notes;
}
@property(nonatomic, retain) NSString *feature;
@property(nonatomic, assign) IP1DeviceTestStatus status;
@property(nonatomic, retain) NSString *notes;
@end
