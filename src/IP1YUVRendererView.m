#import "IP1YUVRendererView.h"

#import <QuartzCore/CAEAGLLayer.h>
#import <OpenGLES/EAGL.h>

static const GLchar *IP1VertexShader =
    "attribute vec4 position;"
    "attribute vec2 texCoord;"
    "varying vec2 vTexCoord;"
    "void main() {"
    "    gl_Position = position;"
    "    vTexCoord = texCoord;"
    "}";

static const GLchar *IP1FragmentShader =
    "precision mediump float;"
    "varying vec2 vTexCoord;"
    "uniform sampler2D SamplerY;"
    "uniform sampler2D SamplerU;"
    "uniform sampler2D SamplerV;"
    "void main() {"
    "    float y = texture2D(SamplerY, vTexCoord).r;"
    "    float u = texture2D(SamplerU, vTexCoord).r - 0.5;"
    "    float v = texture2D(SamplerV, vTexCoord).r - 0.5;"
    "    float r = y + 1.402 * v;"
    "    float g = y - 0.344136 * u - 0.714136 * v;"
    "    float b = y + 1.772 * u;"
    "    gl_FragColor = vec4(r, g, b, 1.0);"
    "}";

static GLuint IP1CompileShader(GLenum type, const GLchar *source)
{
    GLuint shader = glCreateShader(type);
    if (!shader) return 0;

    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);

    GLint ok = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &ok);

    if (!ok) {
        glDeleteShader(shader);
        return 0;
    }

    return shader;
}

@implementation IP1YUVRendererView

@synthesize delegate = _delegate;

- (void)deliverStatusOnMainThread:(NSString *)status
{
    id<IP1YUVRendererViewDelegate> delegate = _delegate;

    if (delegate &&
        [delegate respondsToSelector:@selector(yuvRendererStatus:)]) {
        [delegate yuvRendererStatus:status];
    }
}

- (void)reportStatus:(NSString *)status
{
    if (![status length]) return;

    [self performSelectorOnMainThread:@selector(deliverStatusOnMainThread:)
                           withObject:status
                        waitUntilDone:NO];
}

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.opaque = YES;

        _frameLock = [[NSLock alloc] init];

        _planeY = NULL;
        _planeU = NULL;
        _planeV = NULL;

        _renderPlaneY = NULL;
        _renderPlaneU = NULL;
        _renderPlaneV = NULL;

        _videoWidth = 0;
        _videoHeight = 0;

        _frameReady = NO;
        _drawScheduled = NO;
        _didReportFirstPresent = NO;
    }

    return self;
}

- (BOOL)prepareRenderer
{
    if (_context &&
        _framebuffer &&
        _renderbuffer &&
        _program &&
        _backingWidth > 0 &&
        _backingHeight > 0) {
        return YES;
    }

    /*
     Önceki erken/başarısız drawable denemesini temizle.
    */
    if (_context) {
        [EAGLContext setCurrentContext:_context];

        if (_textureY) {
            glDeleteTextures(1, &_textureY);
            _textureY = 0;
        }

        if (_textureU) {
            glDeleteTextures(1, &_textureU);
            _textureU = 0;
        }

        if (_textureV) {
            glDeleteTextures(1, &_textureV);
            _textureV = 0;
        }

        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }

        if (_framebuffer) {
            glDeleteFramebuffers(1, &_framebuffer);
            _framebuffer = 0;
        }

        if (_renderbuffer) {
            glDeleteRenderbuffers(1, &_renderbuffer);
            _renderbuffer = 0;
        }

        if ([EAGLContext currentContext] == _context)
            [EAGLContext setCurrentContext:nil];

        [_context release];
        _context = nil;
    }

    _backingWidth = 0;
    _backingHeight = 0;

    CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
    layer.opaque = YES;

    _context = [[EAGLContext alloc]
                initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!_context) {
        [self reportStatus:@"GL: EAGLContext oluşturulamadı"];
        return NO;
    }

    if (![EAGLContext setCurrentContext:_context]) return NO;

    glGenRenderbuffers(1, &_renderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);

    if (![_context renderbufferStorage:GL_RENDERBUFFER
                              fromDrawable:layer]) {
        [self reportStatus:@"GL: renderbufferStorage başarısız"];
        return NO;
    }

    glGetRenderbufferParameteriv(GL_RENDERBUFFER,
                                 GL_RENDERBUFFER_WIDTH,
                                 &_backingWidth);

    glGetRenderbufferParameteriv(GL_RENDERBUFFER,
                                 GL_RENDERBUFFER_HEIGHT,
                                 &_backingHeight);

    if (_backingWidth <= 0 || _backingHeight <= 0) {
        [self reportStatus:
            [NSString stringWithFormat:@"GL: drawable geçersiz %dx%d",
                (int)_backingWidth,
                (int)_backingHeight]];
        return NO;
    }

    [self reportStatus:
        [NSString stringWithFormat:@"GL: drawable %dx%d",
            (int)_backingWidth,
            (int)_backingHeight]];

    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);

    glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                              GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER,
                              _renderbuffer);

    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) !=
        GL_FRAMEBUFFER_COMPLETE) {
        return NO;
    }

    GLuint vertexShader =
        IP1CompileShader(GL_VERTEX_SHADER,
                         IP1VertexShader);

    GLuint fragmentShader =
        IP1CompileShader(GL_FRAGMENT_SHADER,
                         IP1FragmentShader);

    if (!vertexShader || !fragmentShader) {
        [self reportStatus:@"GL: shader compile başarısız"];
        return NO;
    }

    _program = glCreateProgram();

    glAttachShader(_program, vertexShader);
    glAttachShader(_program, fragmentShader);

    glBindAttribLocation(_program, 0, "position");
    glBindAttribLocation(_program, 1, "texCoord");

    glLinkProgram(_program);

    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

    GLint linked = 0;

    glGetProgramiv(_program,
                   GL_LINK_STATUS,
                   &linked);

    if (!linked) {
        [self reportStatus:@"GL: program link başarısız"];
        return NO;
    }

    _positionSlot = 0;
    _texCoordSlot = 1;

    _samplerY =
        glGetUniformLocation(_program, "SamplerY");

    _samplerU =
        glGetUniformLocation(_program, "SamplerU");

    _samplerV =
        glGetUniformLocation(_program, "SamplerV");

    glGenTextures(1, &_textureY);
    glGenTextures(1, &_textureU);
    glGenTextures(1, &_textureV);

    return YES;
}

- (void)submitYPlane:(const uint8_t *)y
             stride:(NSInteger)yStride
             uPlane:(const uint8_t *)u
             stride:(NSInteger)uStride
             vPlane:(const uint8_t *)v
             stride:(NSInteger)vStride
              width:(NSInteger)width
             height:(NSInteger)height
{
    if (!y || !u || !v ||
        width <= 0 || height <= 0)
        return;

    NSUInteger ySize =
        (NSUInteger)width *
        (NSUInteger)height;

    NSUInteger chromaWidth =
        ((NSUInteger)width + 1) / 2;

    NSUInteger chromaHeight =
        ((NSUInteger)height + 1) / 2;

    NSUInteger chromaSize =
        chromaWidth * chromaHeight;

    [_frameLock lock];

    if (_videoWidth != (NSUInteger)width ||
        _videoHeight != (NSUInteger)height ||
        !_planeY || !_planeU || !_planeV) {

        if (_planeY) free(_planeY);
        if (_planeU) free(_planeU);
        if (_planeV) free(_planeV);

        if (_renderPlaneY) free(_renderPlaneY);
        if (_renderPlaneU) free(_renderPlaneU);
        if (_renderPlaneV) free(_renderPlaneV);

        _planeY =
            (unsigned char *)malloc(ySize);

        _planeU =
            (unsigned char *)malloc(chromaSize);

        _planeV =
            (unsigned char *)malloc(chromaSize);

        _renderPlaneY =
            (unsigned char *)malloc(ySize);

        _renderPlaneU =
            (unsigned char *)malloc(chromaSize);

        _renderPlaneV =
            (unsigned char *)malloc(chromaSize);

        _videoWidth = width;
        _videoHeight = height;
    }

    if (!_planeY || !_planeU || !_planeV ||
        !_renderPlaneY || !_renderPlaneU || !_renderPlaneV) {

        _frameReady = NO;
        [_frameLock unlock];
        return;
    }

    NSInteger row;

    for (row = 0; row < height; row++) {
        memcpy(_planeY + row * width,
               y + row * yStride,
               width);
    }

    for (row = 0;
         row < (NSInteger)chromaHeight;
         row++) {

        memcpy(_planeU + row * chromaWidth,
               u + row * uStride,
               chromaWidth);

        memcpy(_planeV + row * chromaWidth,
               v + row * vStride,
               chromaWidth);
    }

    _frameReady = YES;

    /*
     Main thread üzerinde zaten bekleyen/çalışan bir render varsa
     ikinci, üçüncü, dördüncü draw çağrılarını kuyruğa ekleme.
     Yeni frame yalnız back-buffer'ın üzerine yazılır.
    */
    BOOL shouldSchedule = !_drawScheduled;

    if (shouldSchedule)
        _drawScheduled = YES;

    [_frameLock unlock];

    if (shouldSchedule) {
        [self performSelectorOnMainThread:
            @selector(drawLatestFrame)
                               withObject:nil
                            waitUntilDone:NO];
    }
}

- (void)drawLatestFrame
{
    if (![self prepareRenderer]) {
        [self reportStatus:@"GL: renderer hazırlanamadı"];
        return;
    }

    /*
     Back ve front buffer'ı çok kısa süreli lock altında değiştir.
     OpenGL işlemleri boyunca demux/decode thread'i ASLA lock beklemez.
    */
    [_frameLock lock];

    if (!_frameReady ||
        !_planeY ||
        !_planeU ||
        !_planeV) {

        _drawScheduled = NO;
        [_frameLock unlock];
        return;
    }

    unsigned char *tmp = NULL;

    tmp = _renderPlaneY;
    _renderPlaneY = _planeY;
    _planeY = tmp;

    tmp = _renderPlaneU;
    _renderPlaneU = _planeU;
    _planeU = tmp;

    tmp = _renderPlaneV;
    _renderPlaneV = _planeV;
    _planeV = tmp;

    _frameReady = NO;

    GLsizei width =
        (GLsizei)_videoWidth;

    GLsizei height =
        (GLsizei)_videoHeight;

    [_frameLock unlock];

    [EAGLContext setCurrentContext:_context];

    glBindFramebuffer(GL_FRAMEBUFFER,
                      _framebuffer);

    glViewport(0,
               0,
               _backingWidth,
               _backingHeight);

    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);

    glUseProgram(_program);

    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

    GLsizei chromaWidth =
        (width + 1) / 2;

    GLsizei chromaHeight =
        (height + 1) / 2;

#define IP1_UPLOAD_PLANE(unit, texture, data, w, h, sampler) \
    glActiveTexture(unit); \
    glBindTexture(GL_TEXTURE_2D, texture); \
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); \
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); \
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); \
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE); \
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, \
                 w, h, 0, GL_LUMINANCE, \
                 GL_UNSIGNED_BYTE, data); \
    glUniform1i(sampler, (unit - GL_TEXTURE0));

    IP1_UPLOAD_PLANE(GL_TEXTURE0,
                     _textureY,
                     _renderPlaneY,
                     width,
                     height,
                     _samplerY);

    IP1_UPLOAD_PLANE(GL_TEXTURE1,
                     _textureU,
                     _renderPlaneU,
                     chromaWidth,
                     chromaHeight,
                     _samplerU);

    IP1_UPLOAD_PLANE(GL_TEXTURE2,
                     _textureV,
                     _renderPlaneV,
                     chromaWidth,
                     chromaHeight,
                     _samplerV);

#undef IP1_UPLOAD_PLANE

    static const GLfloat vertices[] = {
        -1.0f, -1.0f,
         1.0f, -1.0f,
        -1.0f,  1.0f,
         1.0f,  1.0f
    };

    static const GLfloat texCoords[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 0.0f
    };

    glEnableVertexAttribArray(_positionSlot);
    glVertexAttribPointer(_positionSlot,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          0,
                          vertices);

    glEnableVertexAttribArray(_texCoordSlot);
    glVertexAttribPointer(_texCoordSlot,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          0,
                          texCoords);

    glDrawArrays(GL_TRIANGLE_STRIP,
                 0,
                 4);

    glBindRenderbuffer(GL_RENDERBUFFER,
                       _renderbuffer);

    BOOL presented =
        [_context presentRenderbuffer:GL_RENDERBUFFER];

    /*
     Diagnostic'i yalnız ilk başarılı frame'de göster.
     Her frame için main-thread mesajı üretme.
    */
    if (presented && !_didReportFirstPresent) {
        _didReportFirstPresent = YES;
        [self reportStatus:@"GL: frame PRESENT edildi"];
    } else if (!presented) {
        [self reportStatus:@"GL: presentRenderbuffer başarısız"];
    }

    /*
     Biz OpenGL ile uğraşırken producer yeni frame yazmış olabilir.
     Varsa yalnız BİR yeni draw planla.
    */
    [_frameLock lock];

    BOOL needsAnotherFrame = _frameReady;

    if (!needsAnotherFrame)
        _drawScheduled = NO;

    [_frameLock unlock];

    if (needsAnotherFrame) {
        [self performSelectorOnMainThread:
            @selector(drawLatestFrame)
                               withObject:nil
                            waitUntilDone:NO];
    }
}

- (void)clearFrame
{
    [_frameLock lock];
    _frameReady = NO;
    _drawScheduled = NO;
    [_frameLock unlock];
}

- (void)dealloc
{
    [EAGLContext setCurrentContext:_context];

    if (_textureY)
        glDeleteTextures(1, &_textureY);

    if (_textureU)
        glDeleteTextures(1, &_textureU);

    if (_textureV)
        glDeleteTextures(1, &_textureV);

    if (_program)
        glDeleteProgram(_program);

    if (_framebuffer)
        glDeleteFramebuffers(1, &_framebuffer);

    if (_renderbuffer)
        glDeleteRenderbuffers(1, &_renderbuffer);

    if (_planeY) free(_planeY);
    if (_planeU) free(_planeU);
    if (_planeV) free(_planeV);

    if (_renderPlaneY) free(_renderPlaneY);
    if (_renderPlaneU) free(_renderPlaneU);
    if (_renderPlaneV) free(_renderPlaneV);

    [_frameLock release];

    if ([EAGLContext currentContext] == _context)
        [EAGLContext setCurrentContext:nil];

    [_context release];

    [super dealloc];
}

@end
