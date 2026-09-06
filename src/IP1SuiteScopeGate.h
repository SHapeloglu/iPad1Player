#import <Foundation/Foundation.h>

typedef enum {
    IP1SuiteScopePlayer = 0,
    IP1SuiteScopeFiles,
    IP1SuiteScopePDFReader,
    IP1SuiteScopeDownloader,
    IP1SuiteScopeUnknown
} IP1SuiteScopeTarget;

@interface IP1SuiteScopeGate : NSObject
+ (IP1SuiteScopeTarget)targetForPath:(NSString *)path;
+ (BOOL)playerOwnsPath:(NSString *)path;
+ (BOOL)playerOwnsFeature:(NSString *)featureKey;
+ (NSString *)reasonForFeature:(NSString *)featureKey;
@end
