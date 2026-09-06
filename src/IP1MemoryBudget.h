#import <Foundation/Foundation.h>

@interface IP1MemoryBudget : NSObject
+ (NSUInteger)videoPacketBudgetBytes;
+ (NSUInteger)audioPacketBudgetBytes;
+ (NSUInteger)metadataBudgetBytes;
+ (NSUInteger)maximumDecodedVideoFrames;
+ (NSUInteger)subtitleCueSoftLimit;
+ (BOOL)isLowMemoryProfile;
@end
