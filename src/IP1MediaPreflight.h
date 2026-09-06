#import <Foundation/Foundation.h>

@interface IP1MediaPreflight : NSObject
+ (BOOL)validatePath:(NSString *)path error:(NSString **)errorMessage;
+ (BOOL)isSupportedParseExtension:(NSString *)extension;
+ (unsigned long long)maximumReasonableFileBytes;
@end
