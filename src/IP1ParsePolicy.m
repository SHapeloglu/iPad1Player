#import "IP1ParsePolicy.h"
#import "IP1MemoryBudget.h"

@implementation IP1ParsePolicy

+ (NSUInteger)maximumMetadataBytes { return [IP1MemoryBudget metadataBudgetBytes]; }
+ (NSUInteger)maximumTrackCount { return 24; }
+ (NSUInteger)maximumChapterCount { return 128; }
+ (NSTimeInterval)maximumParseSeconds { return 8.0; }
+ (NSTimeInterval)maximumMediaDurationSeconds { return 8.0 * 60.0 * 60.0; }

+ (BOOL)shouldRejectTrackCount:(NSUInteger)trackCount chapterCount:(NSUInteger)chapterCount {
    return (trackCount > [self maximumTrackCount] || chapterCount > [self maximumChapterCount]);
}

@end
