#import <Foundation/Foundation.h>

typedef enum {
    IP1SubtitleEncodingAutomatic = 0,
    IP1SubtitleEncodingUTF8,
    IP1SubtitleEncodingWindows1254,
    IP1SubtitleEncodingISO88599
} IP1SubtitleEncoding;

@interface IP1SRTParser : NSObject
+ (NSArray *)parseSRTAtPath:(NSString *)path error:(NSError **)error;
+ (NSArray *)parseSRTAtPath:(NSString *)path encoding:(IP1SubtitleEncoding)encoding error:(NSError **)error;
+ (NSString *)displayNameForEncoding:(IP1SubtitleEncoding)encoding;
@end
