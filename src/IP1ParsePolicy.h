#import <Foundation/Foundation.h>

@interface IP1ParsePolicy : NSObject
+ (NSUInteger)maximumMetadataBytes;
+ (NSUInteger)maximumTrackCount;
+ (NSUInteger)maximumChapterCount;
+ (NSTimeInterval)maximumParseSeconds;
+ (NSTimeInterval)maximumMediaDurationSeconds;
+ (BOOL)shouldRejectTrackCount:(NSUInteger)trackCount chapterCount:(NSUInteger)chapterCount;
@end
