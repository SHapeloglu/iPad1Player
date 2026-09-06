#import "IP1FramePolicy.h"

@implementation IP1FramePolicy

+ (IP1FrameDecision)decisionForFramePTS:(NSTimeInterval)framePTS
                             masterTime:(NSTimeInterval)masterTime
                          earlyTolerance:(NSTimeInterval)earlyTolerance
                           lateTolerance:(NSTimeInterval)lateTolerance {
    NSTimeInterval delta = framePTS - masterTime;
    if (delta > earlyTolerance) return IP1FrameDecisionWait;
    if (delta < -lateTolerance) return IP1FrameDecisionDrop;
    return IP1FrameDecisionRender;
}

@end
