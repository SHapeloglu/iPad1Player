#import <Foundation/Foundation.h>

typedef enum {
    IP1CompatibilitySafe = 0,
    IP1CompatibilityTestRequired,
    IP1CompatibilityRejected
} IP1CompatibilityStatus;

@interface IP1CompatibilityGate : NSObject
+ (IP1CompatibilityStatus)statusForFeature:(NSString *)feature;
+ (NSString *)labelForStatus:(IP1CompatibilityStatus)status;
+ (NSDictionary *)report;
@end
