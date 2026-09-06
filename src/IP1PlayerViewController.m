#include <math.h>
#import "IP1PlayerViewController.h"
#import "IP1SRTParser.h"
#import "IP1SubtitleCue.h"
#import "IP1MediaCapabilities.h"
#import "IP1MKVBackend.h"
#import "IP1YUVRendererView.h"
#import "IP1PlaybackProfile.h"
#import "IP1MemoryBudget.h"
#import <MediaPlayer/MediaPlayer.h>

static NSString * const IP1ResumeDefaultsKey = @"IP1ResumePositions";

typedef enum {
    IP1AspectFit = 0,
    IP1AspectFill,
    IP1Aspect4x3,
    IP1Aspect16x9,
    IP1Aspect185,
    IP1Aspect235
} IP1AspectMode;

@interface IP1PlayerViewController () <IP1MKVBackendDelegate, IP1YUVRendererViewDelegate>
@property(nonatomic, retain) MPMoviePlayerController *moviePlayer;
@property(nonatomic, retain) IP1MKVBackend *mkvBackend;
@property(nonatomic, retain) IP1YUVRendererView *yuvRendererView;
@property(nonatomic, retain) UILabel *subtitleLabel;
@property(nonatomic, retain) UILabel *statusLabel;
@property(nonatomic, retain) UIView *quickControlsView;
@property(nonatomic, retain) UIButton *subtitleToggleButton;
@property(nonatomic, retain) UIButton *aspectButton;
@property(nonatomic, retain) UIButton *speedButton;
@property(nonatomic, retain) UIButton *lockButton;
@property(nonatomic, retain) NSTimer *subtitleTimer;
@property(nonatomic, retain) NSTimer *resumeTimer;
@property(nonatomic, retain) NSTimer *sleepTimer;
@property(nonatomic, retain) NSArray *subtitleCues;
@property(nonatomic, retain) NSArray *subtitlePaths;
@property(nonatomic, retain) NSString *currentSubtitlePath;
@property(nonatomic, retain) NSString *currentMediaPath;
@property(nonatomic, assign) NSTimeInterval subtitleOffset;
@property(nonatomic, assign) BOOL subtitlesEnabled;
@property(nonatomic, assign) BOOL controlsLocked;
@property(nonatomic, assign) CGFloat subtitleFontSize;
@property(nonatomic, assign) CGFloat subtitleVerticalOffset;
@property(nonatomic, assign) NSInteger selectedSubtitleIndex;
@property(nonatomic, assign) NSInteger activeSubtitleCueIndex;
@property(nonatomic, assign) CGFloat originalBrightness;
@property(nonatomic, assign) BOOL brightnessWasChanged;
@property(nonatomic, assign) IP1SubtitleEncoding subtitleEncoding;
@property(nonatomic, assign) IP1AspectMode aspectMode;
@property(nonatomic, assign) NSInteger playbackRateIndex;
@property(nonatomic, assign) NSTimeInterval repeatA;
@property(nonatomic, assign) NSTimeInterval repeatB;
@end

@implementation IP1PlayerViewController
@synthesize moviePlayer = _moviePlayer;
@synthesize mkvBackend = _mkvBackend;
@synthesize yuvRendererView = _yuvRendererView;
@synthesize subtitleLabel = _subtitleLabel;
@synthesize statusLabel = _statusLabel;
@synthesize quickControlsView = _quickControlsView;
@synthesize subtitleToggleButton = _subtitleToggleButton;
@synthesize aspectButton = _aspectButton;
@synthesize speedButton = _speedButton;
@synthesize lockButton = _lockButton;
@synthesize subtitleTimer = _subtitleTimer;
@synthesize resumeTimer = _resumeTimer;
@synthesize sleepTimer = _sleepTimer;
@synthesize subtitleCues = _subtitleCues;
@synthesize subtitlePaths = _subtitlePaths;
@synthesize currentSubtitlePath = _currentSubtitlePath;
@synthesize currentMediaPath = _currentMediaPath;
@synthesize subtitleOffset = _subtitleOffset;
@synthesize subtitlesEnabled = _subtitlesEnabled;
@synthesize controlsLocked = _controlsLocked;
@synthesize subtitleFontSize = _subtitleFontSize;
@synthesize subtitleVerticalOffset = _subtitleVerticalOffset;
@synthesize selectedSubtitleIndex = _selectedSubtitleIndex;
@synthesize activeSubtitleCueIndex = _activeSubtitleCueIndex;
@synthesize originalBrightness = _originalBrightness;
@synthesize brightnessWasChanged = _brightnessWasChanged;
@synthesize subtitleEncoding = _subtitleEncoding;
@synthesize aspectMode = _aspectMode;
@synthesize playbackRateIndex = _playbackRateIndex;
@synthesize repeatA = _repeatA;
@synthesize repeatB = _repeatB;

- (void)loadView {
    UIView *root = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    root.backgroundColor = [UIColor blackColor];
    self.view = root;

    IP1YUVRendererView *renderer =
        [[[IP1YUVRendererView alloc] initWithFrame:root.bounds] autorelease];

    renderer.autoresizingMask =
        UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;

    [root addSubview:renderer];
    self.yuvRendererView = renderer;
    self.yuvRendererView.delegate = self;

    /*
     CAEAGLLayer henüz window'a bağlanmadan drawable oluşturma.
     Renderer ilk gerçek frame geldiğinde hazırlanacak.
    */

    self.subtitlesEnabled = YES;
    self.subtitleOffset = 0.0;
    self.subtitleFontSize = 24.0;
    self.subtitleVerticalOffset = 0.0;
    self.subtitleEncoding = IP1SubtitleEncodingAutomatic;
    self.aspectMode = IP1AspectFit;
    self.playbackRateIndex = 2;
    self.repeatA = -1.0;
    self.repeatB = -1.0;
    self.originalBrightness = [UIScreen mainScreen].brightness;
    self.brightnessWasChanged = NO;

    UILabel *status = [[[UILabel alloc] initWithFrame:CGRectMake(80, 18, root.bounds.size.width - 160, 36)] autorelease];
    status.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    status.backgroundColor = [UIColor clearColor];
    status.textColor = [UIColor lightGrayColor];
    status.textAlignment = UITextAlignmentCenter;
    status.font = [UIFont systemFontOfSize:14.0];
    status.text = @"iPad1Player — medyayı iPad1Files gibi bir suite uygulamasından açın.";
    [root addSubview:status];
    self.statusLabel = status;

    UILabel *renderDiag =
        [[[UILabel alloc] initWithFrame:
            CGRectMake(80, 50, root.bounds.size.width - 160, 30)]
            autorelease];

    renderDiag.tag = 9091;
    renderDiag.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    renderDiag.backgroundColor = [UIColor clearColor];
    renderDiag.textColor = [UIColor yellowColor];
    renderDiag.textAlignment = UITextAlignmentCenter;
    renderDiag.font = [UIFont boldSystemFontOfSize:13.0];
    renderDiag.text = @"GL/YUV: bekleniyor...";

    [root addSubview:renderDiag];

    UIButton *lock = [self buttonWithTitle:@"Kilitle" action:@selector(toggleControlsLock:) frame:CGRectMake(root.bounds.size.width - 78, 14, 66, 38)];
    lock.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [root addSubview:lock];
    self.lockButton = lock;

    UILabel *subtitle = [[[UILabel alloc] initWithFrame:CGRectMake(40, root.bounds.size.height - 205, root.bounds.size.width - 80, 105)] autorelease];
    subtitle.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    subtitle.backgroundColor = [UIColor colorWithWhite:0 alpha:0.55];
    subtitle.textColor = [UIColor whiteColor];
    subtitle.textAlignment = UITextAlignmentCenter;
    subtitle.numberOfLines = 0;
    subtitle.font = [UIFont boldSystemFontOfSize:self.subtitleFontSize];
    subtitle.hidden = YES;
    [root addSubview:subtitle];
    self.subtitleLabel = subtitle;

    UIView *controls = [[[UIView alloc] initWithFrame:CGRectMake(0, root.bounds.size.height - 82, root.bounds.size.width, 66)] autorelease];
    controls.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    controls.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.86];
    [root addSubview:controls];
    self.quickControlsView = controls;

    CGFloat w = 112.0, gap = 8.0, x = 12.0;
    UIButton *subToggle = [self buttonWithTitle:@"SRT Açık" action:@selector(toggleSubtitles:) frame:CGRectMake(x, 13, w, 40)];
    [controls addSubview:subToggle]; self.subtitleToggleButton = subToggle; x += w + gap;
    [controls addSubview:[self buttonWithTitle:@"SRT -0.5" action:@selector(subtitleEarlier:) frame:CGRectMake(x, 13, w, 40)]]; x += w + gap;
    [controls addSubview:[self buttonWithTitle:@"SRT +0.5" action:@selector(subtitleLater:) frame:CGRectMake(x, 13, w, 40)]]; x += w + gap;
    UIButton *aspect = [self buttonWithTitle:@"Aspect Fit" action:@selector(cycleAspect:) frame:CGRectMake(x, 13, w, 40)];
    [controls addSubview:aspect]; self.aspectButton = aspect; x += w + gap;
    UIButton *speed = [self buttonWithTitle:@"Hız 1.0x" action:@selector(cyclePlaybackSpeed:) frame:CGRectMake(x, 13, w, 40)];
    [controls addSubview:speed]; self.speedButton = speed; x += w + gap;
    [controls addSubview:[self buttonWithTitle:@"Seçenekler" action:@selector(showOptions:) frame:CGRectMake(x, 13, w, 40)]];

    UISwipeGestureRecognizer *left = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSeekSwipe:)] autorelease];
    left.direction = UISwipeGestureRecognizerDirectionLeft; [root addGestureRecognizer:left];
    UISwipeGestureRecognizer *right = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSeekSwipe:)] autorelease];
    right.direction = UISwipeGestureRecognizerDirectionRight; [root addGestureRecognizer:right];
    UIPanGestureRecognizer *vertical = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleVerticalPan:)] autorelease];
    vertical.maximumNumberOfTouches = 1; [root addGestureRecognizer:vertical];
}

- (UIButton *)buttonWithTitle:(NSString *)title action:(SEL)action frame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = frame; [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (NSString *)decodedPathFromExternalURL:(NSURL *)url {
    if ([[url scheme] isEqualToString:@"file"]) return [url path];
    if (![[url scheme] isEqualToString:@"ipad1player"]) return nil;
    NSString *absolute = [url absoluteString]; NSRange r = [absolute rangeOfString:@"path="];
    if (r.location == NSNotFound) return nil;
    NSString *value = [absolute substringFromIndex:r.location + r.length];
    NSRange amp = [value rangeOfString:@"&"]; if (amp.location != NSNotFound) value = [value substringToIndex:amp.location];
    return [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (BOOL)openExternalURL:(NSURL *)url {
    NSString *path = [self decodedPathFromExternalURL:url];
    if (![path length] || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        self.statusLabel.text = @"Medya yolu geçersiz veya erişilemiyor."; return NO;
    }
    NSString *ext = [[path pathExtension] lowercaseString];
    NSSet *media = [NSSet setWithObjects:@"mp4",@"mov",@"m4v",@"mkv",@"avi",nil];
    if (![media containsObject:ext]) {
        self.statusLabel.text = @"Bu dosya iPad1Player kapsamı dışında; uygun suite uygulamasına yönlendirilmelidir."; return NO;
    }
    [self playMediaAtPath:path]; return YES;
}

- (void)playMediaAtPath:(NSString *)path {
    [self saveResumePosition];
    NSString *ext = [[path pathExtension] lowercaseString];
    if ([IP1MediaCapabilities isFFmpegContainerExtension:ext]) {
        [self stopTimers];

        [self.moviePlayer stop];
        [self.moviePlayer.view removeFromSuperview];
        self.moviePlayer = nil;

        if (self.mkvBackend) {
            [self.mkvBackend pauseAudioRuntime];
            [self.mkvBackend stop];
            self.mkvBackend = nil;
        }

        self.currentMediaPath = path;
        self.subtitleOffset = 0.0;
        self.subtitlesEnabled = YES;

        IP1MKVBackend *backend =
            [[[IP1MKVBackend alloc] init] autorelease];
        self.mkvBackend = backend;
        self.mkvBackend.delegate = self;
        self.yuvRendererView.hidden = NO;
        [self.yuvRendererView clearFrame];

        NSString *audioError = nil;
        if (![self.mkvBackend prepareAudioRuntimeAtPath:path
                                      audioStreamIndex:-1
                                                 error:&audioError]) {
            self.statusLabel.text =
                (audioError ? audioError : @"AAC/MP3 audio hazırlanamadı.");
            [self.mkvBackend stop];
            self.mkvBackend = nil;
            return;
        }

        [self loadExternalSubtitlesForMediaPath:path];

        [self.mkvBackend startAudioRuntime];

        [[UIApplication sharedApplication]
            setIdleTimerDisabled:YES];

        self.statusLabel.text =
            [NSString stringWithFormat:
                @"%@ FFmpeg: audio runtime başlatıldı...",
                [ext uppercaseString]];

        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(checkFFmpegAudioRuntime:)
                                                   object:nil];

        [self performSelector:@selector(checkFFmpegAudioRuntime:)
                   withObject:nil
                   afterDelay:2.0];

        return;
    }

    self.yuvRendererView.hidden = YES;
    [self.yuvRendererView clearFrame];

    if (self.mkvBackend) {
        [self.mkvBackend pauseAudioRuntime];
        [self.mkvBackend stop];
        self.mkvBackend = nil;
    }

    [self stopTimers]; [self.moviePlayer stop]; [self.moviePlayer.view removeFromSuperview];
    self.currentMediaPath = path; self.subtitleOffset = 0.0; self.subtitlesEnabled = YES;
    self.repeatA = -1.0; self.repeatB = -1.0;
    [self.subtitleToggleButton setTitle:@"SRT Açık" forState:UIControlStateNormal];

    self.moviePlayer = [[[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:path]] autorelease];
    self.moviePlayer.view.frame = self.view.bounds;
    self.moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
    self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    [self.view insertSubview:self.moviePlayer.view atIndex:0];
    [self loadExternalSubtitlesForMediaPath:path];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackStateChanged:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    [self.moviePlayer prepareToPlay];
    NSTimeInterval resume = [self resumePositionForPath:path]; if (resume > 5.0) self.moviePlayer.initialPlaybackTime = resume;
    [self.moviePlayer play]; [self applyPlaybackRate];
    self.resumeTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(periodicResumeSave:) userInfo:nil repeats:YES];
    self.statusLabel.text = [path lastPathComponent];
}

- (void)checkFFmpegAudioRuntime:(id)sender {
    (void)sender;

    if (!self.mkvBackend) {
        self.statusLabel.text = @"FFmpeg audio backend aktif değil.";
        return;
    }

    NSTimeInterval decoded = [self.mkvBackend audioRuntimeTime];

    NSInteger videoFrames =
        [self.mkvBackend videoRuntimeDecodedFrameCount];

    NSInteger videoWidth =
        [self.mkvBackend videoRuntimeWidth];

    NSInteger videoHeight =
        [self.mkvBackend videoRuntimeHeight];

    if (decoded > 0.05) {
        self.statusLabel.text =
            [NSString stringWithFormat:
                @"Audio %.2f sn OK | Video %ld frame %ldx%ld",
                decoded,
                (long)videoFrames,
                (long)videoWidth,
                (long)videoHeight];
    } else {
        self.statusLabel.text =
            [NSString stringWithFormat:
                @"Audio PCM yok | Video %ld frame %ldx%ld",
                (long)videoFrames,
                (long)videoWidth,
                (long)videoHeight];
    }
}

- (void)mkvBackendDidDecodeY:(const uint8_t *)y
                         yStride:(NSInteger)yStride
                               u:(const uint8_t *)u
                         uStride:(NSInteger)uStride
                               v:(const uint8_t *)v
                         vStride:(NSInteger)vStride
                           width:(NSInteger)width
                          height:(NSInteger)height {

    [self.yuvRendererView submitYPlane:y
                               stride:yStride
                               uPlane:u
                               stride:uStride
                               vPlane:v
                               stride:vStride
                                width:width
                               height:height];
}

- (void)setRenderDiagnosticText:(NSString *)text
{
    UILabel *label = (UILabel *)[self.view viewWithTag:9091];

    if (label && [text length]) {
        label.text = text;
    }
}

- (void)reportRenderDiagnostic:(NSString *)text
{
    if (![text length]) return;

    [self performSelectorOnMainThread:
        @selector(setRenderDiagnosticText:)
                           withObject:text
                        waitUntilDone:NO];
}

- (void)yuvRendererStatus:(NSString *)status
{
    if ([status length]) {
        [self setRenderDiagnosticText:status];
    }
}

- (NSArray *)matchingSubtitlePathsForMediaPath:(NSString *)path {
    NSString *dir = [path stringByDeletingLastPathComponent];
    NSString *base = [[path lastPathComponent] stringByDeletingPathExtension];
    NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil];
    NSMutableArray *matches = [NSMutableArray array];
    for (NSString *name in items) {
        if (![[[name pathExtension] lowercaseString] isEqualToString:@"srt"]) continue;
        NSString *stem = [name stringByDeletingPathExtension];
        if ([stem isEqualToString:base] || [stem hasPrefix:[base stringByAppendingString:@"-"]] || [stem hasPrefix:[base stringByAppendingString:@"."]]) {
            [matches addObject:[dir stringByAppendingPathComponent:name]];
        }
    }
    [matches sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return matches;
}

- (void)loadExternalSubtitlesForMediaPath:(NSString *)path {
    self.subtitlePaths = [self matchingSubtitlePathsForMediaPath:path]; self.selectedSubtitleIndex = 0; self.activeSubtitleCueIndex = -1;
    if ([self.subtitlePaths count]) [self loadSubtitleAtPath:[self.subtitlePaths objectAtIndex:0]];
    else [self loadSubtitleAtPath:nil];
}

- (void)loadSubtitleAtPath:(NSString *)path {
    self.subtitleCues = nil; self.activeSubtitleCueIndex = -1; self.currentSubtitlePath = path; self.subtitleLabel.hidden = YES;
    [self.subtitleTimer invalidate]; self.subtitleTimer = nil;
    if (![path length] || ![[NSFileManager defaultManager] fileExistsAtPath:path]) return;
    NSError *error = nil;
    NSArray *cues = [IP1SRTParser parseSRTAtPath:path encoding:self.subtitleEncoding error:&error];
    if (![cues count]) { [self showTemporaryStatus:(error ? [error localizedDescription] : @"Altyazı okunamadı")]; return; }
    self.subtitleCues = cues;
    self.subtitleTimer = [NSTimer scheduledTimerWithTimeInterval:0.10 target:self selector:@selector(updateSubtitle:) userInfo:nil repeats:YES];
}


- (NSInteger)subtitleCueIndexForTime:(NSTimeInterval)time {
    NSInteger count = (NSInteger)[self.subtitleCues count];
    if (count <= 0) return -1;

    NSInteger low = 0;
    NSInteger high = count - 1;
    NSInteger candidate = -1;

    while (low <= high) {
        NSInteger mid = low + ((high - low) / 2);
        IP1SubtitleCue *cue = [self.subtitleCues objectAtIndex:mid];
        if (time < cue.startTime) {
            high = mid - 1;
        } else {
            candidate = mid;
            low = mid + 1;
        }
    }

    if (candidate >= 0) {
        IP1SubtitleCue *cue = [self.subtitleCues objectAtIndex:candidate];
        if (time >= cue.startTime && time <= cue.endTime) return candidate;
    }
    return -1;
}

- (void)updateSubtitle:(NSTimer *)timer {
    (void)timer;
    if (self.repeatA >= 0.0 && self.repeatB > self.repeatA && self.moviePlayer.currentPlaybackTime >= self.repeatB) {
        self.moviePlayer.currentPlaybackTime = self.repeatA;
        self.activeSubtitleCueIndex = -1;
    }

    if (!self.subtitlesEnabled || ![self.subtitleCues count]) {
        self.subtitleLabel.hidden = YES;
        return;
    }

    NSTimeInterval time = self.moviePlayer.currentPlaybackTime + self.subtitleOffset;
    NSInteger count = (NSInteger)[self.subtitleCues count];
    NSInteger idx = self.activeSubtitleCueIndex;

    /* O(1) fast path during normal sequential playback. */
    if (idx >= 0 && idx < count) {
        IP1SubtitleCue *current = [self.subtitleCues objectAtIndex:idx];
        if (time >= current.startTime && time <= current.endTime) {
            if (![self.subtitleLabel.text isEqualToString:current.text]) self.subtitleLabel.text = current.text;
            self.subtitleLabel.hidden = NO;
            return;
        }

        NSInteger next = idx + 1;
        if (next < count) {
            IP1SubtitleCue *nextCue = [self.subtitleCues objectAtIndex:next];
            if (time >= nextCue.startTime && time <= nextCue.endTime) {
                self.activeSubtitleCueIndex = next;
                self.subtitleLabel.text = nextCue.text;
                self.subtitleLabel.hidden = NO;
                return;
            }
        }
    }

    /* Seek/jump path: O(log n) binary search instead of rescanning all cues. */
    idx = [self subtitleCueIndexForTime:time];
    self.activeSubtitleCueIndex = idx;
    if (idx >= 0) {
        IP1SubtitleCue *cue = [self.subtitleCues objectAtIndex:idx];
        self.subtitleLabel.text = cue.text;
        self.subtitleLabel.hidden = NO;
    } else {
        self.subtitleLabel.text = nil;
        self.subtitleLabel.hidden = YES;
    }
}

- (void)toggleSubtitles:(id)sender { self.subtitlesEnabled = !self.subtitlesEnabled; [self.subtitleToggleButton setTitle:(self.subtitlesEnabled ? @"SRT Açık" : @"SRT Kapalı") forState:UIControlStateNormal]; if (!self.subtitlesEnabled) self.subtitleLabel.hidden = YES; }
- (void)subtitleEarlier:(id)sender { self.subtitleOffset -= 0.5; [self showTemporaryStatus:[NSString stringWithFormat:@"Altyazı: %+.1f sn", self.subtitleOffset]]; }
- (void)subtitleLater:(id)sender { self.subtitleOffset += 0.5; [self showTemporaryStatus:[NSString stringWithFormat:@"Altyazı: %+.1f sn", self.subtitleOffset]]; }

- (NSArray *)aspectTitles { return [NSArray arrayWithObjects:@"Fit",@"Fill",@"4:3",@"16:9",@"1.85",@"2.35",nil]; }
- (void)cycleAspect:(id)sender { self.aspectMode = (self.aspectMode + 1) % 6; [self applyAspect]; [self.aspectButton setTitle:[NSString stringWithFormat:@"Aspect %@", [[self aspectTitles] objectAtIndex:self.aspectMode]] forState:UIControlStateNormal]; }
- (void)applyAspect {
    if (!self.moviePlayer) return;
    if (self.aspectMode == IP1AspectFit || self.aspectMode == IP1AspectFill) {
        self.moviePlayer.view.frame = self.view.bounds;
        self.moviePlayer.scalingMode = (self.aspectMode == IP1AspectFill) ? MPMovieScalingModeAspectFill : MPMovieScalingModeAspectFit; return;
    }
    CGFloat ratio = 4.0/3.0; if (self.aspectMode == IP1Aspect16x9) ratio = 16.0/9.0; else if (self.aspectMode == IP1Aspect185) ratio = 1.85; else if (self.aspectMode == IP1Aspect235) ratio = 2.35;
    CGRect b = self.view.bounds; CGFloat width = b.size.width, height = width / ratio;
    if (height > b.size.height) { height = b.size.height; width = height * ratio; }
    self.moviePlayer.view.frame = CGRectMake((b.size.width-width)/2.0, (b.size.height-height)/2.0, width, height);
    self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
}

- (NSArray *)playbackRates { return [IP1PlaybackProfile safePlaybackRates]; }
- (void)cyclePlaybackSpeed:(id)sender { self.playbackRateIndex = (self.playbackRateIndex + 1) % [[self playbackRates] count]; [self applyPlaybackRate]; }
- (void)applyPlaybackRate { if (!self.moviePlayer) return; float rate = [[[self playbackRates] objectAtIndex:self.playbackRateIndex] floatValue]; self.moviePlayer.currentPlaybackRate = rate; [self.speedButton setTitle:[NSString stringWithFormat:@"Hız %.2gx", rate] forState:UIControlStateNormal]; }

- (void)showOptions:(id)sender {
    UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:@"Player Seçenekleri" delegate:self cancelButtonTitle:@"Kapat" destructiveButtonTitle:nil otherButtonTitles:@"Sonraki altyazı", @"Altyazı encoding", @"Altyazı boyut +", @"Altyazı boyut -", @"Altyazı yukarı", @"Altyazı aşağı", @"A noktası", @"B noktası", @"A-B temizle", @"Medya bilgisi", nil] autorelease];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) return;
    switch (buttonIndex) {
        case 0: [self selectNextSubtitle]; break;
        case 1: [self cycleSubtitleEncoding]; break;
        case 2: [self changeSubtitleFontBy:2.0]; break;
        case 3: [self changeSubtitleFontBy:-2.0]; break;
        case 4: [self moveSubtitleBy:-12.0]; break;
        case 5: [self moveSubtitleBy:12.0]; break;
        case 6: self.repeatA = self.moviePlayer.currentPlaybackTime; [self showTemporaryStatus:@"A noktası kaydedildi"]; break;
        case 7: self.repeatB = self.moviePlayer.currentPlaybackTime; [self showTemporaryStatus:@"B noktası kaydedildi"]; break;
        case 8: self.repeatA = self.repeatB = -1.0; [self showTemporaryStatus:@"A-B tekrar kapalı"]; break;
        case 9: [self showMediaInfo]; break;
        default: break;
    }
}

- (void)selectNextSubtitle {
    if (![self.subtitlePaths count]) { [self showTemporaryStatus:@"Harici SRT bulunamadı"]; return; }
    self.selectedSubtitleIndex = (self.selectedSubtitleIndex + 1) % [self.subtitlePaths count];
    NSString *path = [self.subtitlePaths objectAtIndex:self.selectedSubtitleIndex]; [self loadSubtitleAtPath:path];
    [self showTemporaryStatus:[NSString stringWithFormat:@"SRT: %@", [path lastPathComponent]]];
}
- (void)cycleSubtitleEncoding { self.subtitleEncoding = (self.subtitleEncoding + 1) % 4; if ([self.currentSubtitlePath length]) [self loadSubtitleAtPath:self.currentSubtitlePath]; [self showTemporaryStatus:[NSString stringWithFormat:@"Encoding: %@", [IP1SRTParser displayNameForEncoding:self.subtitleEncoding]]]; }
- (void)changeSubtitleFontBy:(CGFloat)delta { self.subtitleFontSize = MIN(40.0, MAX(14.0, self.subtitleFontSize + delta)); self.subtitleLabel.font = [UIFont boldSystemFontOfSize:self.subtitleFontSize]; [self showTemporaryStatus:[NSString stringWithFormat:@"Altyazı: %.0f pt", self.subtitleFontSize]]; }
- (void)moveSubtitleBy:(CGFloat)delta { self.subtitleVerticalOffset = MIN(120.0, MAX(-120.0, self.subtitleVerticalOffset + delta)); CGRect f = self.subtitleLabel.frame; f.origin.y = self.view.bounds.size.height - 205 + self.subtitleVerticalOffset; self.subtitleLabel.frame = f; [self showTemporaryStatus:[NSString stringWithFormat:@"Altyazı konumu: %+.0f", self.subtitleVerticalOffset]]; }

- (void)showMediaInfo {
    if (!self.moviePlayer || ![self.currentMediaPath length]) return;
    CGSize s = self.moviePlayer.naturalSize;
    NSString *message = [NSString stringWithFormat:@"Dosya: %@\nContainer: %@\nÇözünürlük: %.0f x %.0f\nSüre: %.1f dk\nBackend: Apple MediaPlayer\nMKV/track codec ayrıntıları FFmpeg backend ile gelecek.", [self.currentMediaPath lastPathComponent], [[[self.currentMediaPath pathExtension] uppercaseString] description], s.width, s.height, self.moviePlayer.duration/60.0];
    UIAlertView *a = [[[UIAlertView alloc] initWithTitle:@"Medya Bilgisi" message:message delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease]; [a show];
}

- (void)toggleControlsLock:(id)sender { self.controlsLocked = !self.controlsLocked; self.quickControlsView.hidden = self.controlsLocked; [self.lockButton setTitle:(self.controlsLocked ? @"Kilidi Aç" : @"Kilitle") forState:UIControlStateNormal]; [self showTemporaryStatus:(self.controlsLocked ? @"Kontroller kilitlendi" : @"Kontroller açıldı")]; }

- (void)handleSeekSwipe:(UISwipeGestureRecognizer *)gesture {
    if (self.controlsLocked || !self.moviePlayer) return; NSTimeInterval current = self.moviePlayer.currentPlaybackTime;
    NSTimeInterval target = current + (gesture.direction == UISwipeGestureRecognizerDirectionRight ? 10.0 : -10.0); if (target < 0.0) target = 0.0;
    if (self.moviePlayer.duration > 0.0 && target > self.moviePlayer.duration) target = self.moviePlayer.duration; self.moviePlayer.currentPlaybackTime = target;
    [self showTemporaryStatus:(gesture.direction == UISwipeGestureRecognizerDirectionRight ? @"+10 sn" : @"-10 sn")];
}

- (void)handleVerticalPan:(UIPanGestureRecognizer *)pan {
    if (self.controlsLocked || !self.moviePlayer) return;
    CGPoint v = [pan velocityInView:self.view];
    if (fabs(v.y) < fabs(v.x)) return;

    static NSTimeInterval last = 0;
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if (now - last < 0.08) return;
    last = now;

    CGPoint point = [pan locationInView:self.view];
    float delta = (v.y < 0 ? 0.025f : -0.025f);

    if (point.x < self.view.bounds.size.width / 2.0) {
        CGFloat brightness = [UIScreen mainScreen].brightness + delta;
        [UIScreen mainScreen].brightness = MIN(1.0, MAX(0.0, brightness));
        self.brightnessWasChanged = YES;
        [self showTemporaryStatus:[NSString stringWithFormat:@"Parlaklık: %.0f%%", [UIScreen mainScreen].brightness * 100.0]];
    } else {
        /*
         iOS 5.1.1 MPMoviePlayerController does not expose a volume property.
         Use the legacy MediaPlayer application volume API instead.

         Keep IPAD1_TEST_REQUIRED until verified on a real iPad 1.
         */
        MPMusicPlayerController *musicPlayer =
            [MPMusicPlayerController applicationMusicPlayer];

        float volume = [musicPlayer volume] + delta;
        volume = MIN(1.0f, MAX(0.0f, volume));

        [musicPlayer setVolume:volume];

        [self showTemporaryStatus:
            [NSString stringWithFormat:@"Ses: %.0f%%",
             volume * 100.0f]];
    }
}

- (void)showTemporaryStatus:(NSString *)text { self.statusLabel.text = text; [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(restoreMediaStatus) object:nil]; [self performSelector:@selector(restoreMediaStatus) withObject:nil afterDelay:1.4]; }
- (void)restoreMediaStatus { if ([self.currentMediaPath length]) self.statusLabel.text = [self.currentMediaPath lastPathComponent]; }
- (NSDictionary *)resumeDictionary { NSDictionary *saved = [[NSUserDefaults standardUserDefaults] dictionaryForKey:IP1ResumeDefaultsKey]; return saved ? saved : [NSDictionary dictionary]; }
- (NSTimeInterval)resumePositionForPath:(NSString *)path { NSNumber *value = [[self resumeDictionary] objectForKey:path]; return value ? [value doubleValue] : 0.0; }
- (void)saveResumePosition {
    if (![self.currentMediaPath length] || !self.moviePlayer) return; NSTimeInterval current = self.moviePlayer.currentPlaybackTime, duration = self.moviePlayer.duration;
    NSMutableDictionary *positions = [NSMutableDictionary dictionaryWithDictionary:[self resumeDictionary]];
    if (current < 5.0 || (duration > 0.0 && current >= duration - 8.0)) [positions removeObjectForKey:self.currentMediaPath]; else [positions setObject:[NSNumber numberWithDouble:current] forKey:self.currentMediaPath];
    [[NSUserDefaults standardUserDefaults] setObject:positions forKey:IP1ResumeDefaultsKey];
}
- (void)periodicResumeSave:(NSTimer *)timer { [self saveResumePosition]; }
- (void)moviePlaybackStateChanged:(NSNotification *)notification { if (self.moviePlayer.playbackState == MPMoviePlaybackStatePaused || self.moviePlayer.playbackState == MPMoviePlaybackStateStopped) [self saveResumePosition]; }
- (void)moviePlaybackFinished:(NSNotification *)notification { [self saveResumePosition]; [[UIApplication sharedApplication] setIdleTimerDisabled:NO]; }
- (void)stopTimers { [self.subtitleTimer invalidate]; self.subtitleTimer = nil; [self.resumeTimer invalidate]; self.resumeTimer = nil; [self.sleepTimer invalidate]; self.sleepTimer = nil; }
- (void)viewDidDisappear:(BOOL)animated { [super viewDidDisappear:animated]; [self saveResumePosition]; [[UIApplication sharedApplication] setIdleTimerDisabled:NO]; if (self.brightnessWasChanged) { [UIScreen mainScreen].brightness = self.originalBrightness; self.brightnessWasChanged = NO; } }
- (void)viewDidLayoutSubviews { [super viewDidLayoutSubviews]; [self applyAspect]; CGRect f = self.subtitleLabel.frame; f.origin.y = self.view.bounds.size.height - 205 + self.subtitleVerticalOffset; f.size.width = self.view.bounds.size.width - 80; self.subtitleLabel.frame = f; }
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation { return YES; }


- (void)setSleepTimerMinutes:(NSInteger)minutes {
    [self.sleepTimer invalidate];
    self.sleepTimer = nil;
    if (minutes <= 0) {
        self.statusLabel.text = @"Uyku zamanlayıcısı kapalı.";
        return;
    }
    self.sleepTimer = [NSTimer scheduledTimerWithTimeInterval:(minutes * 60.0)
                                                     target:self
                                                   selector:@selector(sleepTimerFired:)
                                                   userInfo:nil
                                                    repeats:NO];
    self.statusLabel.text = [NSString stringWithFormat:@"Uyku zamanlayıcısı: %ld dk", (long)minutes];
}

- (void)sleepTimerFired:(NSTimer *)timer {
    (void)timer;
    [self.moviePlayer pause];
    self.statusLabel.text = @"Uyku zamanlayıcısı oynatmayı durdurdu.";
    self.sleepTimer = nil;
}


- (void)savePlaybackStateForBackground {
    [self saveResumePosition];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    /*
     iPad 1: purge only nonessential state. Keep current subtitle cues so
     active playback is not broken, but release discoverable sidecar list.
    */
    if ([self.subtitlePaths count] > 1) {
        NSString *current = [[self.currentSubtitlePath copy] autorelease];
        self.subtitlePaths = (current ? [NSArray arrayWithObject:current] : nil);
        self.selectedSubtitleIndex = 0;
    }

    [self showTemporaryStatus:@"Düşük bellek: gereksiz önbellekler temizlendi."];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self]; [NSObject cancelPreviousPerformRequestsWithTarget:self]; [self saveResumePosition]; [self stopTimers];
    [_subtitleCues release]; [_subtitlePaths release]; [_currentSubtitlePath release]; [_currentMediaPath release]; [_subtitleToggleButton release]; [_aspectButton release]; [_speedButton release]; [_lockButton release]; [_quickControlsView release]; [_subtitleLabel release]; [_statusLabel release]; [_moviePlayer stop]; [_moviePlayer release]; [_mkvBackend pauseAudioRuntime]; [_mkvBackend stop]; [_mkvBackend release]; [_yuvRendererView release]; [super dealloc];
}
@end
