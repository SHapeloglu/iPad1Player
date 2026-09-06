#import <Foundation/Foundation.h>

typedef enum {
    IP1H264DecodeDecisionUnsupported = 0,
    IP1H264DecodeDecisionSoftware,
    IP1H264DecodeDecisionLegacyHardwareTest
} IP1H264DecodeDecision;

@interface IP1H264DecodePolicy : NSObject
+ (IP1H264DecodeDecision)decisionForWidth:(NSInteger)width
                                   height:(NSInteger)height
                   legacyHardwareAvailable:(BOOL)legacyHardwareAvailable;
+ (BOOL)isSoftwareTargetWidth:(NSInteger)width height:(NSInteger)height;
+ (BOOL)is720ClassWidth:(NSInteger)width height:(NSInteger)height;
+ (NSString *)reasonForDecision:(IP1H264DecodeDecision)decision
                          width:(NSInteger)width
                         height:(NSInteger)height;
@end
