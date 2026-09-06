#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class EAGLContext;

@protocol IP1YUVRendererViewDelegate <NSObject>
@optional
- (void)yuvRendererStatus:(NSString *)status;
@end

@interface IP1YUVRendererView : UIView {
@private
    EAGLContext *_context;

    GLuint _framebuffer;
    GLuint _renderbuffer;
    GLuint _program;

    GLuint _textureY;
    GLuint _textureU;
    GLuint _textureV;

    GLint _positionSlot;
    GLint _texCoordSlot;
    GLint _samplerY;
    GLint _samplerU;
    GLint _samplerV;

    GLint _backingWidth;
    GLint _backingHeight;

    NSUInteger _videoWidth;
    NSUInteger _videoHeight;

    /*
     Producer/back buffer:
     demux/decode thread yalnız buraya yazar.
    */
    unsigned char *_planeY;
    unsigned char *_planeU;
    unsigned char *_planeV;

    /*
     Render/front buffer:
     main thread OpenGL'e yalnız buradan okur.
    */
    unsigned char *_renderPlaneY;
    unsigned char *_renderPlaneU;
    unsigned char *_renderPlaneV;

    BOOL _frameReady;
    BOOL _drawScheduled;
    BOOL _didReportFirstPresent;

    NSLock *_frameLock;
    id<IP1YUVRendererViewDelegate> _delegate;
}

@property(nonatomic, assign) id<IP1YUVRendererViewDelegate> delegate;

- (BOOL)prepareRenderer;

- (void)submitYPlane:(const uint8_t *)y
             stride:(NSInteger)yStride
             uPlane:(const uint8_t *)u
             stride:(NSInteger)uStride
             vPlane:(const uint8_t *)v
             stride:(NSInteger)vStride
              width:(NSInteger)width
             height:(NSInteger)height;

- (void)clearFrame;

@end
