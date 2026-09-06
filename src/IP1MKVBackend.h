#import <Foundation/Foundation.h>
@class IP1MediaTrack;
@class IP1Chapter;
@class IP1MediaInfo;
@class IP1FFmpegAdapter;
@class IP1FFmpegParseResult;
@class IP1VideoDecodeCapability;
@class IP1FFmpegAudioSession;

typedef enum {
    IP1MKVDecodeModeAutomatic = 0,
    IP1MKVDecodeModeSoftware,
    IP1MKVDecodeModeLegacyHardware
} IP1MKVDecodeMode;

@protocol IP1MKVBackendDelegate <NSObject>
@optional
- (void)mkvBackendDidBecomeReady;
- (void)mkvBackendDidReachEnd;
- (void)mkvBackendDidFailWithMessage:(NSString *)message;
- (void)mkvBackendVideoTimeDidChange:(NSTimeInterval)time;

- (void)mkvBackendDidDecodeY:(const uint8_t *)y
                     yStride:(NSInteger)yStride
                           u:(const uint8_t *)u
                     uStride:(NSInteger)uStride
                           v:(const uint8_t *)v
                     vStride:(NSInteger)vStride
                       width:(NSInteger)width
                      height:(NSInteger)height;
@end

@interface IP1MKVBackend : NSObject {
@private
    id<IP1MKVBackendDelegate> _delegate;
    NSString *_mediaPath;
    NSArray *_audioTracks;
    NSArray *_subtitleTracks;
    NSInteger _selectedAudioTrack;
    NSInteger _selectedSubtitleTrack;
    NSTimeInterval _audioDelay;
    NSTimeInterval _subtitleDelay;
    IP1MKVDecodeMode _decodeMode;
    IP1FFmpegAdapter *_adapter;
    NSArray *_chapters;
    IP1MediaInfo *_detailedMediaInfo;
    IP1FFmpegAudioSession *_audioSession;
}
@property(nonatomic, assign) id<IP1MKVBackendDelegate> delegate;
@property(nonatomic, retain) NSString *mediaPath;
@property(nonatomic, retain) NSArray *audioTracks;
@property(nonatomic, retain) NSArray *subtitleTracks;
@property(nonatomic, assign) NSInteger selectedAudioTrack;
@property(nonatomic, assign) NSInteger selectedSubtitleTrack;
@property(nonatomic, assign) NSTimeInterval audioDelay;
@property(nonatomic, assign) NSTimeInterval subtitleDelay;
@property(nonatomic, assign) IP1MKVDecodeMode decodeMode;
@property(nonatomic, retain) NSArray *chapters;
@property(nonatomic, retain) IP1MediaInfo *detailedMediaInfo;

+ (BOOL)isAvailable;
+ (NSString *)statusText;
+ (BOOL)supportsEmbeddedSubtitles;
+ (BOOL)supportsMultipleAudioTracks;
+ (BOOL)supportsAudioDelay;
+ (BOOL)supportsHardwareH264;

- (BOOL)openPath:(NSString *)path error:(NSString **)errorMessage;
- (IP1FFmpegParseResult *)parseMetadataAtPath:(NSString *)path error:(NSString **)errorMessage;
- (void)play;
- (void)pause;
- (void)stop;
- (void)seekToTime:(NSTimeInterval)time;
- (NSTimeInterval)currentTime;
- (NSTimeInterval)duration;
- (NSDictionary *)mediaInfo;
- (BOOL)selectAudioTrackAtIndex:(NSInteger)index error:(NSString **)errorMessage;
- (BOOL)selectSubtitleTrackAtIndex:(NSInteger)index error:(NSString **)errorMessage;
- (void)handleMemoryWarning;
- (BOOL)prepareAudioRuntimeAtPath:(NSString *)path audioStreamIndex:(NSInteger)streamIndex error:(NSString **)errorMessage;
- (void)startAudioRuntime;
- (void)pauseAudioRuntime;
- (NSTimeInterval)audioRuntimeTime;
- (NSInteger)videoRuntimeDecodedFrameCount;
- (NSInteger)videoRuntimeWidth;
- (NSInteger)videoRuntimeHeight;
- (IP1VideoDecodeCapability *)videoDecodeCapabilityForMediaInfo:(IP1MediaInfo *)info;
@end
