#import "IP1PCMRingBuffer.h"

@implementation IP1PCMRingBuffer

- (id)initWithCapacityBytes:(NSUInteger)capacityBytes {
    self = [super init];
    if (self) {
        _capacityBytes = MAX((NSUInteger)4096, capacityBytes);
        _storage = [[NSMutableData alloc] initWithLength:_capacityBytes];
        _readOffset = 0;
        _writeOffset = 0;
        _usedBytes = 0;
    }
    return self;
}

- (NSUInteger)capacityBytes { return _capacityBytes; }
- (NSUInteger)usedBytes { return _usedBytes; }

- (NSUInteger)writeBytes:(const void *)bytes length:(NSUInteger)length {
    if (!bytes || length == 0) return 0;
    NSUInteger freeBytes = _capacityBytes - _usedBytes;
    NSUInteger toWrite = MIN(length, freeBytes);
    if (!toWrite) return 0;

    unsigned char *dst = (unsigned char *)[_storage mutableBytes];
    NSUInteger first = MIN(toWrite, _capacityBytes - _writeOffset);
    memcpy(dst + _writeOffset, bytes, first);

    NSUInteger remaining = toWrite - first;
    if (remaining) memcpy(dst, ((const unsigned char *)bytes) + first, remaining);

    _writeOffset = (_writeOffset + toWrite) % _capacityBytes;
    _usedBytes += toWrite;
    return toWrite;
}

- (NSUInteger)readBytes:(void *)buffer length:(NSUInteger)length {
    if (!buffer || length == 0 || _usedBytes == 0) return 0;
    NSUInteger toRead = MIN(length, _usedBytes);

    const unsigned char *src = (const unsigned char *)[_storage bytes];
    NSUInteger first = MIN(toRead, _capacityBytes - _readOffset);
    memcpy(buffer, src + _readOffset, first);

    NSUInteger remaining = toRead - first;
    if (remaining) memcpy(((unsigned char *)buffer) + first, src, remaining);

    _readOffset = (_readOffset + toRead) % _capacityBytes;
    _usedBytes -= toRead;
    return toRead;
}

- (void)flush {
    _readOffset = 0;
    _writeOffset = 0;
    _usedBytes = 0;
}

- (void)dealloc {
    [_storage release];
    [super dealloc];
}
@end
