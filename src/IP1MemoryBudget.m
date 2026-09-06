#import "IP1MemoryBudget.h"

@implementation IP1MemoryBudget

+ (NSUInteger)videoPacketBudgetBytes { return 3 * 1024 * 1024; }
+ (NSUInteger)audioPacketBudgetBytes { return 768 * 1024; }
+ (NSUInteger)metadataBudgetBytes { return 384 * 1024; }
+ (NSUInteger)maximumDecodedVideoFrames { return 2; }
+ (NSUInteger)subtitleCueSoftLimit { return 5000; }
+ (BOOL)isLowMemoryProfile { return YES; }

@end
