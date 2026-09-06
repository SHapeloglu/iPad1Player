#import "IP1FFmpegAdapter.h"
#import "IP1PacketQueue.h"
#import "IP1PlaybackClock.h"
#import "IP1FramePolicy.h"
#import "IP1MediaTrack.h"
#import "IP1FFmpegParseResult.h"
#import "IP1MediaInfo.h"
#import "IP1Chapter.h"
#import "IP1MemoryBudget.h"
#import "IP1StreamMetadataMapper.h"
#import "IP1ParsePolicy.h"
#import "IP1ParseDiagnostics.h"
#import "IP1FFmpegCompat.h"

@implementation IP1FFmpegAdapter
@synthesize delegate = _delegate;
@synthesize path = _path;
@synthesize tracks = _tracks;
@synthesize mediaInfo = _mediaInfo;
@synthesize chapters = _chapters;

- (id)init {
    self = [super init];
    if (self) {
        /* Conservative compressed-packet budgets for ~256 MB RAM device. */
        _videoPackets = [[IP1PacketQueue alloc] initWithMaxItems:72 maxBytes:[IP1MemoryBudget videoPacketBudgetBytes]];
        _audioPackets = [[IP1PacketQueue alloc] initWithMaxItems:96 maxBytes:[IP1MemoryBudget audioPacketBudgetBytes]];
        _opened = NO;
        _playing = NO;
        _eof = NO;
        _duration = 0.0;
        _clock = [[IP1PlaybackClock alloc] init];
    }
    return self;
}

- (BOOL)opened { return _opened; }
- (BOOL)playing { return _playing; }
- (BOOL)eof { return _eof; }


- (IP1FFmpegParseResult *)parseMediaAtPath:(NSString *)path error:(NSString **)errorMessage {
#ifndef IP1_FFMPEG_BACKEND
    if (errorMessage) *errorMessage = @"FFmpeg parse backend bu derlemede etkin değil.";
    return nil;
#else
    if (![path length]) {
        if (errorMessage) *errorMessage = @"FFmpeg parse yolu boş.";
        return nil;
    }

    AVFormatContext *formatContext = NULL;
    int rc = avformat_open_input(&formatContext, [path fileSystemRepresentation], NULL, NULL);
    if (rc < 0 || !formatContext) {
        if (errorMessage) *errorMessage = @"FFmpeg medya containerını açamadı.";
        if (formatContext) avformat_close_input(&formatContext);
        return nil;
    }

    /*
     Parse-only mode: find stream information but never start decoder threads
     or prebuffer packets. This keeps the operation appropriate for iPad 1.
    */
    rc = avformat_find_stream_info(formatContext, NULL);
    if (rc < 0) {
        if (errorMessage) *errorMessage = @"FFmpeg stream bilgilerini okuyamadı.";
        avformat_close_input(&formatContext);
        return nil;
    }

    if (formatContext->nb_streams > [IP1ParsePolicy maximumTrackCount]) {
        if (errorMessage) *errorMessage = @"FFmpeg track sayısı iPad 1 güvenlik limitini aşıyor.";
        avformat_close_input(&formatContext);
        return nil;
    }

    NSMutableArray *tracks = [NSMutableArray arrayWithCapacity:formatContext->nb_streams];
    NSMutableArray *chapters = [NSMutableArray arrayWithCapacity:MIN((NSUInteger)formatContext->nb_chapters,
                                                                     [IP1ParsePolicy maximumChapterCount])];
    IP1MediaInfo *info = [[[IP1MediaInfo alloc] init] autorelease];

    if (formatContext->iformat && formatContext->iformat->name) {
        info.container = [NSString stringWithUTF8String:formatContext->iformat->name];
    } else {
        info.container = @"";
    }

    if (formatContext->duration != AV_NOPTS_VALUE && formatContext->duration > 0) {
        info.duration = ((double)formatContext->duration / (double)AV_TIME_BASE);
    } else {
        info.duration = 0.0;
    }

    info.bitrate = (formatContext->bit_rate > 0 ? formatContext->bit_rate : 0);

    BOOL selectedVideo = NO;
    BOOL selectedAudio = NO;
    unsigned int i;
    for (i = 0; i < formatContext->nb_streams; i++) {
        AVStream *stream = formatContext->streams[i];
        enum AVMediaType mediaType = IP1FFStreamType(stream);
        if (mediaType != AVMEDIA_TYPE_VIDEO &&
            mediaType != AVMEDIA_TYPE_AUDIO &&
            mediaType != AVMEDIA_TYPE_SUBTITLE) {
            continue;
        }

        IP1MediaTrack *track = [[[IP1MediaTrack alloc] init] autorelease];
        track.streamIndex = (NSInteger)i;

        if (mediaType == AVMEDIA_TYPE_VIDEO) {
            track.type = IP1MediaTrackVideo;
            track.selected = !selectedVideo;
            selectedVideo = YES;
        } else if (mediaType == AVMEDIA_TYPE_AUDIO) {
            track.type = IP1MediaTrackAudio;
            track.selected = !selectedAudio;
            selectedAudio = YES;
        } else {
            track.type = IP1MediaTrackSubtitle;
            track.selected = NO;
        }

        enum AVCodecID codecID = IP1FFStreamCodecID(stream);
        const char *codecName = avcodec_get_name(codecID);
        track.codecName = codecName ? [NSString stringWithUTF8String:codecName] : @"unknown";

        AVDictionaryEntry *lang = av_dict_get(stream->metadata, "language", NULL, 0);
        AVDictionaryEntry *title = av_dict_get(stream->metadata, "title", NULL, 0);
        NSString *language = (lang && lang->value) ? [NSString stringWithUTF8String:lang->value] : nil;
        NSString *streamTitle = (title && title->value) ? [NSString stringWithUTF8String:title->value] : nil;
        track.language = [IP1StreamMetadataMapper normalizedLanguage:language];
        track.title = [IP1StreamMetadataMapper safeTitle:streamTitle];

        if (mediaType == AVMEDIA_TYPE_VIDEO && ![info.videoCodec length]) {
            info.videoCodec = track.codecName;
            info.width = IP1FFStreamWidth(stream);
            info.height = IP1FFStreamHeight(stream);

            AVRational rate = stream->avg_frame_rate;
            if (rate.num <= 0 || rate.den <= 0) rate = stream->r_frame_rate;
            info.fps = (rate.num > 0 && rate.den > 0) ? av_q2d(rate) : 0.0;
        }

        if (mediaType == AVMEDIA_TYPE_AUDIO && ![info.audioCodec length]) {
            info.audioCodec = track.codecName;
            info.sampleRate = IP1FFStreamSampleRate(stream);
            info.channels = IP1FFStreamChannels(stream);
        }

        [tracks addObject:track];
    }

    if (formatContext->nb_chapters > [IP1ParsePolicy maximumChapterCount]) {
        if (errorMessage) *errorMessage = @"FFmpeg chapter sayısı iPad 1 güvenlik limitini aşıyor.";
        avformat_close_input(&formatContext);
        return nil;
    }

    for (i = 0; i < formatContext->nb_chapters; i++) {
        AVChapter *source = formatContext->chapters[i];
        IP1Chapter *chapter = [[[IP1Chapter alloc] init] autorelease];

        if (source && source->time_base.den != 0) {
            chapter.startTime = ((double)source->start *
                                 (double)source->time_base.num /
                                 (double)source->time_base.den);
        } else {
            chapter.startTime = 0.0;
        }

        AVDictionaryEntry *title = source ? av_dict_get(source->metadata, "title", NULL, 0) : NULL;
        NSString *chapterTitle = (title && title->value) ? [NSString stringWithUTF8String:title->value] : nil;
        chapter.title = [IP1StreamMetadataMapper safeTitle:chapterTitle];
        [chapters addObject:chapter];
    }

    IP1FFmpegParseResult *result = [[[IP1FFmpegParseResult alloc] init] autorelease];
    result.tracks = tracks;
    result.chapters = chapters;
    result.mediaInfo = info;

    /*
     Critical iPad 1 rule: parse-only calls leave no AVFormatContext alive.
     No decoder has been opened and no packet queue has been filled.
    */
    avformat_close_input(&formatContext);
    return result;
#endif
}


- (IP1FFmpegParseResult *)parseAndCloseMediaAtPath:(NSString *)path error:(NSString **)errorMessage {
    NSTimeInterval started = [NSDate timeIntervalSinceReferenceDate];

    IP1FFmpegParseResult *result = [self parseMediaAtPath:path error:errorMessage];
    if (!result) return nil;

    IP1ParseDiagnostics *diag = [[[IP1ParseDiagnostics alloc] init] autorelease];
    diag.elapsedSeconds = [NSDate timeIntervalSinceReferenceDate] - started;
    diag.trackCount = [result.tracks count];
    diag.chapterCount = [result.chapters count];
    diag.withinLimits = ![IP1ParsePolicy shouldRejectTrackCount:diag.trackCount chapterCount:diag.chapterCount]
                        && diag.elapsedSeconds <= [IP1ParsePolicy maximumParseSeconds];
    diag.message = (diag.withinLimits ? @"Parse limitleri içinde." : @"Parse limitlerinden biri aşıldı.");
    result.diagnostics = diag;

    /*
     Parse-only contract: no decoder state, queues or FFmpeg contexts may remain
     retained after metadata extraction.
    */
    [self close];
    return result;
}

- (BOOL)open:(NSString *)path error:(NSString **)errorMessage {
    self.path = path;
#ifndef IP1_FFMPEG_BACKEND
    if (errorMessage) *errorMessage = @"FFmpeg adapter bu derlemede etkin değil.";
    return NO;
#else
    /*
     Real implementation contract:
     - avformat_open_input
     - avformat_find_stream_info
     - build track list
     - prefer H.264 + AAC/MP3
     - demux into bounded queues
     - software decode fallback is mandatory
     - legacy HW H.264 path only behind verified IP1_LEGACY_H264_HW gate
     */
    if (errorMessage) *errorMessage = @"FFmpeg kütüphaneleri işaretlenmiş ancak adapter implementasyonu tamamlanmadı.";
    return NO;
#endif
}

- (void)close {
    [_videoPackets flush];
    [_audioPackets flush];
    _opened = NO;
    _playing = NO;
    _eof = NO;
    [_clock resetToTime:0.0];
}

- (void)flushForSeek {
    [_videoPackets flush];
    [_audioPackets flush];
}

- (BOOL)seekToTime:(NSTimeInterval)time error:(NSString **)errorMessage {
    (void)time;
    [self flushForSeek];
#ifndef IP1_FFMPEG_BACKEND
    if (errorMessage) *errorMessage = @"Seek için FFmpeg backend gerekli.";
    return NO;
#else
    if (errorMessage) *errorMessage = @"FFmpeg seek adapterı henüz bağlanmadı.";
    return NO;
#endif
}


- (void)play {
    if (!_opened) return;
    _playing = YES;
}

- (void)pause {
    _playing = NO;
}

- (NSTimeInterval)currentTime {
    return [_clock masterTime];
}

- (NSTimeInterval)duration {
    return _duration;
}

- (NSInteger)selectedAudioStreamIndex {
    for (IP1MediaTrack *track in self.tracks) {
        if (track.type == IP1MediaTrackAudio && track.selected) return track.streamIndex;
    }
    return -1;
}

- (NSInteger)selectedSubtitleStreamIndex {
    for (IP1MediaTrack *track in self.tracks) {
        if (track.type == IP1MediaTrackSubtitle && track.selected) return track.streamIndex;
    }
    return -1;
}

- (BOOL)selectAudioStreamIndex:(NSInteger)streamIndex error:(NSString **)errorMessage {
    BOOL found = NO;
    for (IP1MediaTrack *track in self.tracks) {
        if (track.type != IP1MediaTrackAudio) continue;
        track.selected = (track.streamIndex == streamIndex);
        if (track.selected) found = YES;
    }
    if (!found && errorMessage) *errorMessage = @"İstenen audio track bulunamadı.";
    return found;
}

- (BOOL)selectSubtitleStreamIndex:(NSInteger)streamIndex error:(NSString **)errorMessage {
    BOOL found = (streamIndex < 0); /* -1 means subtitles off */
    for (IP1MediaTrack *track in self.tracks) {
        if (track.type != IP1MediaTrackSubtitle) continue;
        track.selected = (track.streamIndex == streamIndex);
        if (track.selected) found = YES;
    }
    if (!found && errorMessage) *errorMessage = @"İstenen subtitle track bulunamadı.";
    return found;
}


- (void)handleMemoryWarning {
    /*
     iPad 1 low-memory policy:
     keep playback state, but immediately shrink compressed packet queues.
     Decoded-frame caches belong to the real decoder/renderer and must also
     be reduced to at most IP1MemoryBudget.maximumDecodedVideoFrames.
    */
    [_videoPackets trimToMaximumItems:24 maximumBytes:(1024 * 1024)];
    [_audioPackets trimToMaximumItems:48 maximumBytes:(256 * 1024)];
}

- (void)dealloc {
    [self close];
    [_path release];
    [_tracks release];
    [_mediaInfo release];
    [_chapters release];
    [_videoPackets release];
    [_audioPackets release];
    [_clock release];
    [super dealloc];
}
@end
