#import <Foundation/Foundation.h>

#ifdef IP1_FFMPEG_BACKEND
#import "IP1FFmpegCompat.h"
#endif

@interface IP1FFmpegVideoDecoder : NSObject {
@private
#ifdef IP1_FFMPEG_BACKEND
    AVCodecContext *_codecContext;
    AVFrame *_frame;
    AVFrame *_lastFrame;
#endif
    BOOL _opened;
    NSInteger _decodedFrameCount;
    NSInteger _width;
    NSInteger _height;
}

@property(nonatomic, readonly) BOOL opened;
@property(nonatomic, readonly) NSInteger decodedFrameCount;
@property(nonatomic, readonly) NSInteger width;
@property(nonatomic, readonly) NSInteger height;

#ifdef IP1_FFMPEG_BACKEND
- (BOOL)openStream:(AVStream *)stream error:(NSString **)errorMessage;
- (NSInteger)decodePacket:(AVPacket *)packet error:(NSString **)errorMessage;

- (BOOL)currentYUV420PWithY:(const uint8_t **)y
                    yStride:(NSInteger *)yStride
                          u:(const uint8_t **)u
                    uStride:(NSInteger *)uStride
                          v:(const uint8_t **)v
                    vStride:(NSInteger *)vStride
                      width:(NSInteger *)width
                     height:(NSInteger *)height;
#endif

- (void)close;

@end
