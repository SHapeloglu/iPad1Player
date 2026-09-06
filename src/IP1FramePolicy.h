#import <Foundation/Foundation.h>

typedef enum {
    IP1FrameDecisionRender = 0,
    IP1FrameDecisionWait,
    IP1FrameDecisionDrop
} IP1FrameDecision;

@interface IP1FramePolicy : NSObject
+ (IP1FrameDecision)decisionForFramePTS:(NSTimeInterval)framePTS
                             masterTime:(NSTimeInterval)masterTime
                          earlyTolerance:(NSTimeInterval)earlyTolerance
                           lateTolerance:(NSTimeInterval)lateTolerance;
@end
