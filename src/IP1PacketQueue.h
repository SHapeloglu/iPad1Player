#import <Foundation/Foundation.h>

@interface IP1PacketQueue : NSObject {
@private
    NSMutableArray *_items;
    NSUInteger _maxItems;
    NSUInteger _maxBytes;
    NSUInteger _currentBytes;
    NSCondition *_condition;
    BOOL _aborted;
}
@property(nonatomic, assign) NSUInteger maxItems;
@property(nonatomic, assign) NSUInteger maxBytes;
@property(nonatomic, readonly) NSUInteger currentBytes;
@property(nonatomic, readonly) NSUInteger count;

- (id)initWithMaxItems:(NSUInteger)maxItems maxBytes:(NSUInteger)maxBytes;
- (BOOL)enqueueObject:(id)object estimatedBytes:(NSUInteger)bytes;
- (id)dequeueObject;
- (void)flush;
- (void)abort;
- (void)trimToMaximumItems:(NSUInteger)maxItems maximumBytes:(NSUInteger)maxBytes;
@end
