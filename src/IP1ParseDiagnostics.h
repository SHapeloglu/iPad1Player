#import <Foundation/Foundation.h>

@interface IP1ParseDiagnostics : NSObject {
@private
    NSTimeInterval _elapsedSeconds;
    NSUInteger _trackCount;
    NSUInteger _chapterCount;
    BOOL _withinLimits;
    NSString *_message;
}
@property(nonatomic, assign) NSTimeInterval elapsedSeconds;
@property(nonatomic, assign) NSUInteger trackCount;
@property(nonatomic, assign) NSUInteger chapterCount;
@property(nonatomic, assign) BOOL withinLimits;
@property(nonatomic, retain) NSString *message;
- (NSDictionary *)dictionaryRepresentation;
@end
