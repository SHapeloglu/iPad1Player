#import <Foundation/Foundation.h>
@class IP1MediaTrack;

@interface IP1StreamMetadataMapper : NSObject
+ (NSString *)normalizedLanguage:(NSString *)language;
+ (NSString *)safeTitle:(NSString *)title;
+ (BOOL)isTrackCountAcceptable:(NSUInteger)count;
@end
