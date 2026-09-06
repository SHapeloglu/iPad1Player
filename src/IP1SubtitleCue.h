#import <Foundation/Foundation.h>

@interface IP1SubtitleCue : NSObject
@property(nonatomic, assign) NSTimeInterval startTime;
@property(nonatomic, assign) NSTimeInterval endTime;
@property(nonatomic, copy) NSString *text;
@end
