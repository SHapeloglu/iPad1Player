#import <Foundation/Foundation.h>

@class IP1MediaTrack;
@class IP1PacketQueue;
@class IP1PlaybackClock;
@class IP1FFmpegParseResult;

@protocol IP1FFmpegAdapterDelegate <NSObject>
@optional
- (void)ffmpegAdapterDidOpen;
- (void)ffmpegAdapterDidReachEnd;
- (void)ffmpegAdapterDidFail:(NSString *)message;
- (void)ffmpegAdapterPresentationTimeDidChange:(NSTimeInterval)time;
@end

@interface IP1FFmpegAdapter : NSObject {
@private
    id<IP1FFmpegAdapterDelegate> _delegate;
    NSString *_path;
    NSArray *_tracks;
    NSDictionary *_mediaInfo;
    NSArray *_chapters;
    IP1PacketQueue *_videoPackets;
    IP1PacketQueue *_audioPackets;
    BOOL _opened;
    BOOL _playing;
    BOOL _eof;
    IP1PlaybackClock *_clock;
    NSTimeInterval _duration;
}
@property(nonatomic, assign) id<IP1FFmpegAdapterDelegate> delegate;
@property(nonatomic, retain) NSString *path;
@property(nonatomic, retain) NSArray *tracks;
@property(nonatomic, retain) NSDictionary *mediaInfo;
@property(nonatomic, retain) NSArray *chapters;
@property(nonatomic, readonly) BOOL opened;
@property(nonatomic, readonly) BOOL playing;
@property(nonatomic, readonly) BOOL eof;

- (BOOL)open:(NSString *)path error:(NSString **)errorMessage;
- (IP1FFmpegParseResult *)parseMediaAtPath:(NSString *)path error:(NSString **)errorMessage;
- (IP1FFmpegParseResult *)parseAndCloseMediaAtPath:(NSString *)path error:(NSString **)errorMessage;
- (void)close;
- (void)flushForSeek;
- (BOOL)seekToTime:(NSTimeInterval)time error:(NSString **)errorMessage;
- (void)play;
- (void)pause;
- (NSTimeInterval)currentTime;
- (NSTimeInterval)duration;
- (NSInteger)selectedAudioStreamIndex;
- (NSInteger)selectedSubtitleStreamIndex;
- (BOOL)selectAudioStreamIndex:(NSInteger)streamIndex error:(NSString **)errorMessage;
- (BOOL)selectSubtitleStreamIndex:(NSInteger)streamIndex error:(NSString **)errorMessage;
- (void)handleMemoryWarning;

/* Adapter boundary only. Real demux/decode is compiled when IP1_FFMPEG_BACKEND is enabled. */
@end
