#import "IP1CompatibilityGate.h"

@implementation IP1CompatibilityGate

+ (IP1CompatibilityStatus)statusForFeature:(NSString *)feature {
    if (![feature length]) return IP1CompatibilityTestRequired;

    static NSSet *safe = nil;
    static NSSet *test = nil;
    static NSSet *rejected = nil;

    if (!safe) {
        safe = [[NSSet alloc] initWithObjects:
                @"external_srt", @"subtitle_delay", @"subtitle_size", @"subtitle_position",
                @"resume", @"chapters_model", @"sleep_timer", @"aspect_ratio",
                @"gesture_seek", @"mkv_demux", @"bounded_packet_queue", nil];

        test = [[NSSet alloc] initWithObjects:
                @"playback_2x", @"ass_basic", @"ac3", @"eac3", @"ffmpeg_parse_only", @"stream_enumeration", @"chapter_extraction", @"detailed_media_info",
                @"legacy_h264_hw_720p", @"software_h264_480p", @"volume_gesture", nil];

        rejected = [[NSSet alloc] initWithObjects:
                    @"software_h264_720p_primary", @"hevc", @"av1", @"vp9",
                    @"4k", @"hdr", @"modern_10bit", nil];
    }

    if ([safe containsObject:feature]) return IP1CompatibilitySafe;
    if ([rejected containsObject:feature]) return IP1CompatibilityRejected;
    if ([test containsObject:feature]) return IP1CompatibilityTestRequired;
    return IP1CompatibilityTestRequired;
}

+ (NSString *)labelForStatus:(IP1CompatibilityStatus)status {
    switch (status) {
        case IP1CompatibilitySafe: return @"IPAD1_SAFE";
        case IP1CompatibilityRejected: return @"IPAD1_REJECTED";
        default: return @"IPAD1_TEST_REQUIRED";
    }
}

+ (NSDictionary *)report {
    NSArray *features = [NSArray arrayWithObjects:
                         @"external_srt", @"resume", @"chapters_model", @"sleep_timer", @"memory_warning_purge", @"safe_playback_profile", @"h264_360p_policy", @"h264_480p_policy", @"parse_context_close", @"metadata_limits",
                         @"gesture_seek", @"mkv_demux", @"bounded_packet_queue",
                         @"playback_2x", @"ass_basic", @"ac3", @"eac3", @"ffmpeg_parse_only", @"stream_enumeration", @"chapter_extraction", @"detailed_media_info",
                         @"legacy_h264_hw_720p", @"software_h264_720p_primary",
                         @"hevc", @"av1", @"vp9", @"4k", @"hdr", @"modern_10bit", nil];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (NSString *feature in features) {
        [result setObject:[self labelForStatus:[self statusForFeature:feature]] forKey:feature];
    }
    return result;
}
@end
