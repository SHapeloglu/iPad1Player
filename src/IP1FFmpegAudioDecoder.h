#import <Foundation/Foundation.h>

#ifdef IP1_FFMPEG_BACKEND
#import "IP1FFmpegCompat.h"
#endif

@interface IP1FFmpegAudioDecoder : NSObject {
@private
#ifdef IP1_FFMPEG_BACKEND
    AVCodecContext *_codecContext;
    AVFrame *_frame;
    struct SwrContext *_swrContext;

    /*
     SwrContext'i her decoded AAC frame'inde yeniden oluşturma.
     Yalnız kaynak/çıktı formatı gerçekten değiştiğinde rebuild et.
    */
    int64_t _swrInputLayout;
    int _swrInputFormat;
    int _swrInputRate;

    int64_t _swrOutputLayout;
    int _swrOutputRate;
    int _swrOutputChannels;
#endif
    NSInteger _streamIndex;
    BOOL _opened;
}
@property(nonatomic, assign) NSInteger streamIndex;
@property(nonatomic, readonly) BOOL opened;

#ifdef IP1_FFMPEG_BACKEND
- (BOOL)openStream:(AVStream *)stream error:(NSString **)errorMessage;
- (NSInteger)decodePacket:(AVPacket *)packet
                 pcmS16LE:(void *)output
                 maxBytes:(NSUInteger)maxBytes
                    error:(NSString **)errorMessage;
#endif
- (void)close;
@end
