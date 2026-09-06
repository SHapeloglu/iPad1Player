#import "IP1H264DecodePolicy.h"

@implementation IP1H264DecodePolicy

+ (BOOL)isSoftwareTargetWidth:(NSInteger)width height:(NSInteger)height {
    if (width <= 0 || height <= 0) return NO;
    NSInteger maxSide = MAX(width, height);
    NSInteger minSide = MIN(width, height);

    /* iPad 1 software-decode target: SD through roughly 480p class. */
    return (maxSide <= 854 && minSide <= 480);
}

+ (BOOL)is720ClassWidth:(NSInteger)width height:(NSInteger)height {
    if (width <= 0 || height <= 0) return NO;
    NSInteger maxSide = MAX(width, height);
    NSInteger minSide = MIN(width, height);
    return (maxSide <= 1280 && minSide <= 720);
}

+ (IP1H264DecodeDecision)decisionForWidth:(NSInteger)width
                                   height:(NSInteger)height
                   legacyHardwareAvailable:(BOOL)legacyHardwareAvailable {
    if ([self isSoftwareTargetWidth:width height:height]) {
        return IP1H264DecodeDecisionSoftware;
    }

    if ([self is720ClassWidth:width height:height] && legacyHardwareAvailable) {
        return IP1H264DecodeDecisionLegacyHardwareTest;
    }

    return IP1H264DecodeDecisionUnsupported;
}

+ (NSString *)reasonForDecision:(IP1H264DecodeDecision)decision
                          width:(NSInteger)width
                         height:(NSInteger)height {
    switch (decision) {
        case IP1H264DecodeDecisionSoftware:
            return [NSString stringWithFormat:@"%ldx%ld: iPad 1 software H.264 test hedefi.",
                    (long)width, (long)height];

        case IP1H264DecodeDecisionLegacyHardwareTest:
            return [NSString stringWithFormat:@"%ldx%ld: yalnız doğrulanmış legacy hardware/hybrid yol ile.",
                    (long)width, (long)height];

        default:
            return [NSString stringWithFormat:@"%ldx%ld: iPad 1 güvenli decode profili dışında.",
                    (long)width, (long)height];
    }
}
@end
