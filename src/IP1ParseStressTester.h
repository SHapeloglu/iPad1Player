#import <Foundation/Foundation.h>
@class IP1MKVBackend;
@class IP1ParseStressResult;

@interface IP1ParseStressTester : NSObject
+ (IP1ParseStressResult *)runWithBackend:(IP1MKVBackend *)backend
                                    path:(NSString *)path
                              iterations:(NSUInteger)iterations;
@end
