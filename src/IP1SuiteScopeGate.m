#import "IP1SuiteScopeGate.h"

@implementation IP1SuiteScopeGate

+ (IP1SuiteScopeTarget)targetForPath:(NSString *)path {
    NSString *ext = [[path pathExtension] lowercaseString];

    if ([ext isEqualToString:@"pdf"]) return IP1SuiteScopePDFReader;

    if ([ext isEqualToString:@"mkv"] ||
        [ext isEqualToString:@"mp4"] ||
        [ext isEqualToString:@"mov"] ||
        [ext isEqualToString:@"m4v"] ||
        [ext isEqualToString:@"avi"] ||
        [ext isEqualToString:@"mp3"] ||
        [ext isEqualToString:@"aac"] ||
        [ext isEqualToString:@"m4a"]) {
        return IP1SuiteScopePlayer;
    }

    return IP1SuiteScopeFiles;
}

+ (BOOL)playerOwnsPath:(NSString *)path {
    return [self targetForPath:path] == IP1SuiteScopePlayer;
}

+ (BOOL)playerOwnsFeature:(NSString *)featureKey {
    if (![featureKey length]) return NO;

    static NSSet *playerFeatures = nil;
    if (!playerFeatures) {
        playerFeatures = [[NSSet alloc] initWithObjects:
                          @"playback", @"pause", @"seek", @"resume",
                          @"demux", @"video_decode", @"audio_decode",
                          @"audio_output", @"av_sync", @"frame_drop",
                          @"renderer", @"aspect_ratio", @"playback_speed",
                          @"external_subtitle", @"embedded_subtitle",
                          @"subtitle_delay", @"audio_delay",
                          @"audio_track_selection", @"subtitle_track_selection",
                          @"chapters", @"media_info", @"playback_diagnostics",
                          nil];
    }
    return [playerFeatures containsObject:featureKey];
}

+ (NSString *)reasonForFeature:(NSString *)featureKey {
    if ([self playerOwnsFeature:featureKey]) {
        return @"iPad1Player kapsamı: medya oynatma ile doğrudan ilgili.";
    }

    if ([featureKey hasPrefix:@"file_"] ||
        [featureKey isEqualToString:@"rename"] ||
        [featureKey isEqualToString:@"copy"] ||
        [featureKey isEqualToString:@"move"] ||
        [featureKey isEqualToString:@"delete"] ||
        [featureKey isEqualToString:@"archive"] ||
        [featureKey isEqualToString:@"directory_browser"]) {
        return @"iPad1Files kapsamı.";
    }

    if ([featureKey hasPrefix:@"pdf_"] ||
        [featureKey isEqualToString:@"document_reader"] ||
        [featureKey isEqualToString:@"text_reader"]) {
        return @"iPad1PDFReader kapsamı.";
    }

    if ([featureKey hasPrefix:@"download_"] ||
        [featureKey isEqualToString:@"download_manager"]) {
        return @"iPad1Downloader kapsamı.";
    }

    return @"Suite responsibility filtresinde ayrıca değerlendirilmelidir.";
}
@end
