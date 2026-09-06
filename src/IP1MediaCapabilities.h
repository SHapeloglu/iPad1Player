#import <Foundation/Foundation.h>

@interface IP1MediaCapabilities : NSObject
+ (NSArray *)nativeContainers;
+ (NSArray *)ffmpegContainers;
+ (NSArray *)tier1VideoCodecs;
+ (NSArray *)tier1AudioCodecs;
+ (NSArray *)tier1SubtitleCodecs;
+ (NSArray *)tier2VideoCodecs;
+ (NSArray *)tier2AudioCodecs;

+ (BOOL)isNativeContainerExtension:(NSString *)extension;
+ (BOOL)isFFmpegContainerExtension:(NSString *)extension;
+ (NSDictionary *)capabilityReport;
@end
