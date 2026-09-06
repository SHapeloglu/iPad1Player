#import <Foundation/Foundation.h>

@interface IP1FFmpegBuildCheck : NSObject
+ (BOOL)isFFmpegBackendCompiled;
+ (BOOL)isLegacyHardwareFlagCompiled;
+ (NSDictionary *)buildReport;
@end
