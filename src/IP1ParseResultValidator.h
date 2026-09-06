#import <Foundation/Foundation.h>
@class IP1FFmpegParseResult;

@interface IP1ParseResultValidator : NSObject
+ (BOOL)validateResult:(IP1FFmpegParseResult *)result error:(NSString **)errorMessage;
@end
