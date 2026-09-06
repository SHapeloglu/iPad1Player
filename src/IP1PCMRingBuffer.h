#import <Foundation/Foundation.h>

@interface IP1PCMRingBuffer : NSObject {
@private
    NSMutableData *_storage;
    NSUInteger _capacityBytes;
    NSUInteger _readOffset;
    NSUInteger _writeOffset;
    NSUInteger _usedBytes;
}
@property(nonatomic, readonly) NSUInteger capacityBytes;
@property(nonatomic, readonly) NSUInteger usedBytes;

- (id)initWithCapacityBytes:(NSUInteger)capacityBytes;
- (NSUInteger)writeBytes:(const void *)bytes length:(NSUInteger)length;
- (NSUInteger)readBytes:(void *)buffer length:(NSUInteger)length;
- (void)flush;
@end
