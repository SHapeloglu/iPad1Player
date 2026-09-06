#import "IP1ParseFallbackPolicy.h"

@implementation IP1ParseFallbackPolicy

+ (IP1ParseFallbackAction)actionForExtension:(NSString *)extension ffmpegAvailable:(BOOL)ffmpegAvailable {
    NSString *ext = [extension lowercaseString];

    if ([ext isEqualToString:@"mp4"] || [ext isEqualToString:@"mov"] || [ext isEqualToString:@"m4v"]) {
        return IP1ParseFallbackNativeMetadataOnly;
    }

    if ([ext isEqualToString:@"mkv"] || [ext isEqualToString:@"avi"]) {
        return ffmpegAvailable ? IP1ParseFallbackNone : IP1ParseFallbackReject;
    }

    return IP1ParseFallbackReject;
}
@end
