#import "IP1MKVBackend.h"
#import "IP1FFmpegAdapter.h"
#import "IP1MediaInfo.h"
#import "IP1MediaTrack.h"
#import "IP1FFmpegParseResult.h"
#import "IP1ParseResultValidator.h"
#import "IP1MediaPreflight.h"
#import "IP1H264DecodePolicy.h"
#import "IP1VideoDecodeCapability.h"
#import "IP1FFmpegAudioSession.h"

@implementation IP1MKVBackend
@synthesize delegate = _delegate;
@synthesize mediaPath = _mediaPath;
@synthesize audioTracks = _audioTracks;
@synthesize subtitleTracks = _subtitleTracks;
@synthesize selectedAudioTrack = _selectedAudioTrack;
@synthesize selectedSubtitleTrack = _selectedSubtitleTrack;
@synthesize audioDelay = _audioDelay;
@synthesize subtitleDelay = _subtitleDelay;
@synthesize decodeMode = _decodeMode;
@synthesize chapters = _chapters;
@synthesize detailedMediaInfo = _detailedMediaInfo;

+ (BOOL)isAvailable {
#ifdef IP1_FFMPEG_BACKEND
    return YES;
#else
    return NO;
#endif
}

+ (NSString *)statusText {
#ifdef IP1_FFMPEG_BACKEND
    return @"FFmpeg MKV backend etkin";
#else
    return @"FFmpeg MKV backend linklenmedi";
#endif
}

+ (BOOL)supportsEmbeddedSubtitles { return [self isAvailable]; }
+ (BOOL)supportsMultipleAudioTracks { return [self isAvailable]; }
+ (BOOL)supportsAudioDelay { return [self isAvailable]; }

+ (BOOL)supportsHardwareH264 {
#ifdef IP1_LEGACY_H264_HW
    return YES;
#else
    return NO;
#endif
}

- (id)init {
    self = [super init];
    if (self) {
        _selectedAudioTrack = -1;
        _selectedSubtitleTrack = -1;
        _audioDelay = 0.0;
        _subtitleDelay = 0.0;
        _decodeMode = IP1MKVDecodeModeAutomatic;
        _adapter = [[IP1FFmpegAdapter alloc] init];
        _audioSession = [[IP1FFmpegAudioSession alloc] init];
        _audioSession.videoDelegate = (id<IP1FFmpegAudioSessionVideoDelegate>)self;
    }
    return self;
}


- (IP1FFmpegParseResult *)parseMetadataAtPath:(NSString *)path error:(NSString **)errorMessage {
    if (![IP1MediaPreflight validatePath:path error:errorMessage]) {
        return nil;
    }

    if (![[self class] isAvailable]) {
        if (errorMessage) *errorMessage = @"FFmpeg parse backend bu derlemede yok.";
        return nil;
    }

    IP1FFmpegParseResult *result = [_adapter parseAndCloseMediaAtPath:path error:errorMessage];
    if (!result) return nil;

    NSString *validationError = nil;
    if (![IP1ParseResultValidator validateResult:result error:&validationError]) {
        if (errorMessage) *errorMessage = validationError;
        return nil;
    }
    return result;
}

- (BOOL)openPath:(NSString *)path error:(NSString **)errorMessage {
    if (![IP1MediaPreflight validatePath:path error:errorMessage]) {
        return NO;
    }
    self.mediaPath = path;
    if (![[self class] isAvailable]) {
        if (errorMessage) *errorMessage = @"Bu derlemede FFmpeg MKV/AVI backend yok.";
        return NO;
    }
    return [_adapter open:path error:errorMessage];
}

- (void)play { [_adapter play]; }
- (void)pause { [_adapter pause]; }
- (void)stop { [_adapter close]; }

- (void)seekToTime:(NSTimeInterval)time {
    NSString *error = nil;
    if (![_adapter seekToTime:time error:&error] && error && [_delegate respondsToSelector:@selector(mkvBackendDidFailWithMessage:)]) {
        [_delegate mkvBackendDidFailWithMessage:error];
    }
}

- (NSTimeInterval)currentTime { return [_adapter currentTime]; }
- (NSTimeInterval)duration { return [_adapter duration]; }

- (NSDictionary *)mediaInfo {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            (self.mediaPath ? [self.mediaPath lastPathComponent] : @""), @"file",
            [[self class] statusText], @"backend",
            ([[self class] supportsHardwareH264] ? @"YES" : @"NO"), @"legacyHardwareH264",
            nil];
}


- (BOOL)selectAudioTrackAtIndex:(NSInteger)index error:(NSString **)errorMessage {
    if (index < 0 || index >= (NSInteger)[self.audioTracks count]) {
        if (errorMessage) *errorMessage = @"Audio track index geçersiz.";
        return NO;
    }
    IP1MediaTrack *track = [self.audioTracks objectAtIndex:index];
    BOOL ok = [_adapter selectAudioStreamIndex:track.streamIndex error:errorMessage];
    if (ok) self.selectedAudioTrack = index;
    return ok;
}

- (BOOL)selectSubtitleTrackAtIndex:(NSInteger)index error:(NSString **)errorMessage {
    if (index < 0) {
        BOOL ok = [_adapter selectSubtitleStreamIndex:-1 error:errorMessage];
        if (ok) self.selectedSubtitleTrack = -1;
        return ok;
    }
    if (index >= (NSInteger)[self.subtitleTracks count]) {
        if (errorMessage) *errorMessage = @"Subtitle track index geçersiz.";
        return NO;
    }
    IP1MediaTrack *track = [self.subtitleTracks objectAtIndex:index];
    BOOL ok = [_adapter selectSubtitleStreamIndex:track.streamIndex error:errorMessage];
    if (ok) self.selectedSubtitleTrack = index;
    return ok;
}


- (void)handleMemoryWarning { [_adapter handleMemoryWarning]; }


- (IP1VideoDecodeCapability *)videoDecodeCapabilityForMediaInfo:(IP1MediaInfo *)info {
    if (!info || ![[info.videoCodec lowercaseString] isEqualToString:@"h264"]) {
        IP1VideoDecodeCapability *unsupported = [[[IP1VideoDecodeCapability alloc] init] autorelease];
        unsupported.codec = (info.videoCodec ?: @"");
        unsupported.width = info.width;
        unsupported.height = info.height;
        unsupported.decision = IP1H264DecodeDecisionUnsupported;
        unsupported.reason = @"Alpha16 güvenli decode politikası yalnız H.264 için tanımlı.";
        return unsupported;
    }

    IP1VideoDecodeCapability *cap = [[[IP1VideoDecodeCapability alloc] init] autorelease];
    cap.codec = info.videoCodec;
    cap.width = info.width;
    cap.height = info.height;
    cap.decision = [IP1H264DecodePolicy decisionForWidth:info.width
                                                 height:info.height
                                 legacyHardwareAvailable:[[self class] supportsHardwareH264]];
    cap.reason = [IP1H264DecodePolicy reasonForDecision:cap.decision
                                                 width:info.width
                                                height:info.height];
    return cap;
}


- (BOOL)prepareAudioRuntimeAtPath:(NSString *)path
                 audioStreamIndex:(NSInteger)streamIndex
                            error:(NSString **)errorMessage {
    if (![IP1MediaPreflight validatePath:path error:errorMessage]) return NO;
    return [_audioSession preparePath:path audioStreamIndex:streamIndex error:errorMessage];
}

- (void)startAudioRuntime { [_audioSession start]; }
- (void)pauseAudioRuntime { [_audioSession pause]; }
- (NSTimeInterval)audioRuntimeTime { return [_audioSession decodedAudioTime]; }
- (NSInteger)videoRuntimeDecodedFrameCount { return [_audioSession decodedVideoFrameCount]; }
- (NSInteger)videoRuntimeWidth { return [_audioSession videoWidth]; }
- (NSInteger)videoRuntimeHeight { return [_audioSession videoHeight]; }

- (void)ffmpegAudioSession:(IP1FFmpegAudioSession *)session
                 didDecodeY:(const uint8_t *)y
                    yStride:(NSInteger)yStride
                          u:(const uint8_t *)u
                    uStride:(NSInteger)uStride
                          v:(const uint8_t *)v
                    vStride:(NSInteger)vStride
                      width:(NSInteger)width
                     height:(NSInteger)height {
    (void)session;

    if (_delegate &&
        [_delegate respondsToSelector:
            @selector(mkvBackendDidDecodeY:yStride:u:uStride:v:vStride:width:height:)]) {

        [_delegate mkvBackendDidDecodeY:y
                               yStride:yStride
                                     u:u
                               uStride:uStride
                                     v:v
                               vStride:vStride
                                 width:width
                                height:height];
    }
}

- (void)dealloc {
    [_mediaPath release];
    [_audioTracks release];
    [_subtitleTracks release];
    [_adapter release];
    [_audioSession release];
    [_chapters release];
    [_detailedMediaInfo release];
    [super dealloc];
}
@end
