#import "IP1AudioQueueOutput.h"
#import "IP1PCMRingBuffer.h"
#import <AVFoundation/AVFoundation.h>

static const UInt32 IP1AudioQueueBufferBytes = 16 * 1024;

static void IP1AudioQueueCallback(void *userData,
                                  AudioQueueRef queue,
                                  AudioQueueBufferRef buffer) {
    IP1AudioQueueOutput *output = (IP1AudioQueueOutput *)userData;
    if (!output || !queue || !buffer) return;

    IP1PCMRingBuffer *pcm = [output valueForKey:@"_pcmBuffer"];
    UInt32 bytes = (UInt32)[pcm readBytes:buffer->mAudioData
                                  length:IP1AudioQueueBufferBytes];
    if (bytes == 0) {
        memset(buffer->mAudioData, 0, IP1AudioQueueBufferBytes);
        bytes = IP1AudioQueueBufferBytes;
    }
    buffer->mAudioDataByteSize = bytes;
    AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
}

@implementation IP1AudioQueueOutput

- (id)initWithPCMBuffer:(IP1PCMRingBuffer *)pcmBuffer {
    self = [super init];
    if (self) {
        _pcmBuffer = [pcmBuffer retain];
        _queue = NULL;
        _running = NO;
        memset(&_format, 0, sizeof(_format));
        memset(_buffers, 0, sizeof(_buffers));
    }
    return self;
}

- (BOOL)running { return _running; }

- (BOOL)prepareSampleRate:(Float64)sampleRate channels:(UInt32)channels error:(NSString **)errorMessage {
    [self disposeQueue];

    NSError *sessionError = nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];

    if (![session setCategory:AVAudioSessionCategoryPlayback error:&sessionError]) {
        if (errorMessage) {
            *errorMessage = [NSString stringWithFormat:
                @"Audio session category ayarlanamadı: %@",
                [sessionError localizedDescription]];
        }
        return NO;
    }

    sessionError = nil;
    if (![session setActive:YES error:&sessionError]) {
        if (errorMessage) {
            *errorMessage = [NSString stringWithFormat:
                @"Audio session aktif edilemedi: %@",
                [sessionError localizedDescription]];
        }
        return NO;
    }

    if (channels == 0 || channels > 2) channels = 2;
    if (sampleRate <= 0) sampleRate = 44100.0;

    _format.mSampleRate = sampleRate;
    _format.mFormatID = kAudioFormatLinearPCM;
    _format.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    _format.mBitsPerChannel = 16;
    _format.mChannelsPerFrame = channels;
    _format.mFramesPerPacket = 1;
    _format.mBytesPerFrame = channels * 2;
    _format.mBytesPerPacket = _format.mBytesPerFrame;

    OSStatus status = AudioQueueNewOutput(&_format,
                                          IP1AudioQueueCallback,
                                          self,
                                          NULL,
                                          NULL,
                                          0,
                                          &_queue);
    if (status != noErr || !_queue) {
        if (errorMessage) *errorMessage = @"AudioQueue oluşturulamadı.";
        [self disposeQueue];
        return NO;
    }

    UInt32 i;
    for (i = 0; i < 3; i++) {
        status = AudioQueueAllocateBuffer(_queue, IP1AudioQueueBufferBytes, &_buffers[i]);
        if (status != noErr || !_buffers[i]) {
            if (errorMessage) *errorMessage = @"AudioQueue buffer ayrılamadı.";
            [self disposeQueue];
            return NO;
        }
        memset(_buffers[i]->mAudioData, 0, IP1AudioQueueBufferBytes);
        _buffers[i]->mAudioDataByteSize = IP1AudioQueueBufferBytes;
        AudioQueueEnqueueBuffer(_queue, _buffers[i], 0, NULL);
    }

    return YES;
}

- (void)start {
    if (!_queue || _running) return;

    OSStatus status = AudioQueueStart(_queue, NULL);

    if (status == noErr) {
        _running = YES;
    } else {
        _running = NO;
        NSLog(@"iPad1Player AudioQueueStart failed: %ld", (long)status);
    }
}

- (void)pause {
    if (!_queue || !_running) return;
    AudioQueuePause(_queue);
    _running = NO;
}

- (void)stop {
    if (_queue) AudioQueueStop(_queue, true);
    _running = NO;
}

- (void)disposeQueue {
    if (_queue) {
        AudioQueueStop(_queue, true);
        AudioQueueDispose(_queue, true);
        _queue = NULL;
    }
    memset(_buffers, 0, sizeof(_buffers));
    _running = NO;
}

- (void)dealloc {
    [self disposeQueue];
    [_pcmBuffer release];
    [super dealloc];
}
@end
