#import <Foundation/Foundation.h>

typedef enum {
    IP1ParseFallbackNone = 0,
    IP1ParseFallbackNativeMetadataOnly,
    IP1ParseFallbackReject
} IP1ParseFallbackAction;

@interface IP1ParseFallbackPolicy : NSObject
+ (IP1ParseFallbackAction)actionForExtension:(NSString *)extension ffmpegAvailable:(BOOL)ffmpegAvailable;
@end
