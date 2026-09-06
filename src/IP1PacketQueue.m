#import "IP1PacketQueue.h"

@interface IP1QueuedObject : NSObject {
@public
    id object;
    NSUInteger bytes;
}
@end

@implementation IP1QueuedObject

- (void)dealloc {
    [object release];
    [super dealloc];
}

@end


@implementation IP1PacketQueue

@synthesize maxItems = _maxItems;
@synthesize maxBytes = _maxBytes;
@synthesize currentBytes = _currentBytes;

- (id)initWithMaxItems:(NSUInteger)maxItems maxBytes:(NSUInteger)maxBytes {
    self = [super init];

    if (self) {
        _items = [[NSMutableArray alloc] init];
        _condition = [[NSCondition alloc] init];

        _maxItems = maxItems;
        _maxBytes = maxBytes;
        _currentBytes = 0;
        _aborted = NO;
    }

    return self;
}

- (NSUInteger)count {
    [_condition lock];

    NSUInteger count = [_items count];

    [_condition unlock];

    return count;
}

- (BOOL)enqueueObject:(id)obj estimatedBytes:(NSUInteger)estimatedBytes {
    if (!obj) {
        return NO;
    }

    [_condition lock];

    if (_aborted ||
        [_items count] >= _maxItems ||
        (_currentBytes + estimatedBytes) > _maxBytes) {

        [_condition unlock];
        return NO;
    }

    IP1QueuedObject *queued =
        [[[IP1QueuedObject alloc] init] autorelease];

    queued->object = [obj retain];
    queued->bytes = estimatedBytes;

    [_items addObject:queued];

    _currentBytes += estimatedBytes;

    [_condition signal];
    [_condition unlock];

    return YES;
}

- (id)dequeueObject {
    [_condition lock];

    if (_aborted || [_items count] == 0) {
        [_condition unlock];
        return nil;
    }

    IP1QueuedObject *queued =
        [[_items objectAtIndex:0] retain];

    [_items removeObjectAtIndex:0];

    NSUInteger objectBytes = queued->bytes;

    if (_currentBytes >= objectBytes) {
        _currentBytes -= objectBytes;
    } else {
        _currentBytes = 0;
    }

    id obj = [queued->object retain];

    [queued release];

    [_condition unlock];

    return [obj autorelease];
}

- (void)flush {
    [_condition lock];

    [_items removeAllObjects];
    _currentBytes = 0;

    [_condition broadcast];
    [_condition unlock];
}

- (void)abort {
    [_condition lock];

    _aborted = YES;

    [_condition broadcast];
    [_condition unlock];
}

- (void)trimToMaximumItems:(NSUInteger)maximumItems
              maximumBytes:(NSUInteger)maximumBytes {

    [_condition lock];

    while ([_items count] > maximumItems ||
           _currentBytes > maximumBytes) {

        if ([_items count] == 0) {
            break;
        }

        IP1QueuedObject *queued =
            [_items objectAtIndex:0];

        NSUInteger objectBytes = queued->bytes;

        [_items removeObjectAtIndex:0];

        if (_currentBytes >= objectBytes) {
            _currentBytes -= objectBytes;
        } else {
            _currentBytes = 0;
        }
    }

    [_condition broadcast];
    [_condition unlock];
}

- (void)dealloc {
    [self abort];

    [_items release];
    [_condition release];

    [super dealloc];
}

@end
