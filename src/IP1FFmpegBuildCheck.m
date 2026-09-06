#import "IP1FFmpegBuildCheck.h"
#import "IP1FFmpegCompat.h"

@implementation IP1FFmpegBuildCheck

+ (BOOL)isFFmpegBackendCompiled {
#ifdef IP1_FFMPEG_BACKEND
    return YES;
#else
    return NO;
#endif
}

+ (BOOL)isLegacyHardwareFlagCompiled {
#ifdef IP1_LEGACY_H264_HW
    return YES;
#else
    return NO;
#endif
}

+ (NSDictionary *)buildReport {
    NSMutableDictionary *report = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   ([self isFFmpegBackendCompiled] ? @"YES" : @"NO"), @"ffmpegBackend",
                                   ([self isLegacyHardwareFlagCompiled] ? @"YES" : @"NO"), @"legacyH264Flag",
                                   @"armv7", @"arch",
                                   @"iOS 5.1", @"deploymentTarget",
                                   @"MRC", @"memoryManagement",
                                   nil];
#ifdef IP1_FFMPEG_BACKEND
    [report setObject:[NSString stringWithFormat:@"%u", (unsigned int)LIBAVFORMAT_VERSION_MAJOR]
               forKey:@"libavformatMajor"];
    [report setObject:[NSString stringWithFormat:@"%u", (unsigned int)LIBAVCODEC_VERSION_MAJOR]
               forKey:@"libavcodecMajor"];
#endif
    return report;
}
@end
