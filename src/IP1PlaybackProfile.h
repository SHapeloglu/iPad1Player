#import <Foundation/Foundation.h>

@interface IP1PlaybackProfile : NSObject
+ (NSArray *)safePlaybackRates;
+ (BOOL)allowExperimentalTwoX;
+ (BOOL)allowSoftware360pH264;
+ (BOOL)allowSoftware480pH264;
+ (BOOL)allowSoftware720pH264PrimaryPath;
+ (BOOL)allowModernCodecs;
@end
