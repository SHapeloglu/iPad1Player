#import <Foundation/Foundation.h>

@interface IP1ParseStressResult : NSObject {
@private
    NSUInteger _iterationsRequested;
    NSUInteger _iterationsCompleted;
    NSUInteger _failures;
    NSTimeInterval _totalElapsedSeconds;
    BOOL _passed;
    NSString *_lastError;
}
@property(nonatomic, assign) NSUInteger iterationsRequested;
@property(nonatomic, assign) NSUInteger iterationsCompleted;
@property(nonatomic, assign) NSUInteger failures;
@property(nonatomic, assign) NSTimeInterval totalElapsedSeconds;
@property(nonatomic, assign) BOOL passed;
@property(nonatomic, retain) NSString *lastError;
- (NSDictionary *)dictionaryRepresentation;
@end
