#import "IP1StreamMetadataMapper.h"
#import "IP1ParsePolicy.h"

@implementation IP1StreamMetadataMapper

+ (NSString *)normalizedLanguage:(NSString *)language {
    if (![language length]) return @"und";
    NSString *trimmed = [language stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![trimmed length]) return @"und";
    if ([trimmed length] > 12) return [trimmed substringToIndex:12];
    return trimmed;
}

+ (NSString *)safeTitle:(NSString *)title {
    if (![title length]) return @"";
    NSString *trimmed = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmed length] > 80) return [trimmed substringToIndex:80];
    return trimmed;
}

+ (BOOL)isTrackCountAcceptable:(NSUInteger)count {
    return count <= [IP1ParsePolicy maximumTrackCount];
}
@end
