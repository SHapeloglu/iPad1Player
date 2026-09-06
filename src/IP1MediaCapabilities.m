#import "IP1MediaCapabilities.h"
#import "IP1MKVBackend.h"

@implementation IP1MediaCapabilities

+ (NSArray *)nativeContainers {
    return [NSArray arrayWithObjects:@"mp4", @"mov", @"m4v", nil];
}

+ (NSArray *)ffmpegContainers {
    return [NSArray arrayWithObjects:@"mkv", @"avi", nil];
}

+ (NSArray *)tier1VideoCodecs {
    return [NSArray arrayWithObjects:@"H.264/AVC", nil];
}

+ (NSArray *)tier1AudioCodecs {
    return [NSArray arrayWithObjects:@"AAC", @"MP3", nil];
}

+ (NSArray *)tier1SubtitleCodecs {
    return [NSArray arrayWithObjects:@"SRT", @"ASS", @"SSA", nil];
}

+ (NSArray *)tier2VideoCodecs {
    return [NSArray arrayWithObjects:@"MPEG-4 Part 2", @"Xvid", nil];
}

+ (NSArray *)tier2AudioCodecs {
    return [NSArray arrayWithObjects:@"AC3", @"E-AC3", nil];
}

+ (BOOL)isNativeContainerExtension:(NSString *)extension {
    if (![extension length]) return NO;
    return [[self nativeContainers] containsObject:[extension lowercaseString]];
}

+ (BOOL)isFFmpegContainerExtension:(NSString *)extension {
    if (![extension length]) return NO;
    return [[self ffmpegContainers] containsObject:[extension lowercaseString]];
}

+ (NSDictionary *)capabilityReport {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [self nativeContainers], @"nativeContainers",
            [self ffmpegContainers], @"ffmpegContainers",
            [self tier1VideoCodecs], @"tier1VideoCodecs",
            [self tier1AudioCodecs], @"tier1AudioCodecs",
            [self tier1SubtitleCodecs], @"tier1SubtitleCodecs",
            [self tier2VideoCodecs], @"tier2VideoCodecs",
            [self tier2AudioCodecs], @"tier2AudioCodecs",
            ([IP1MKVBackend isAvailable] ? @"YES" : @"NO"), @"ffmpegLinked",
            ([IP1MKVBackend supportsHardwareH264] ? @"YES" : @"NO"), @"legacyHardwareH264",
            @"360p/480p class", @"softwareH264Target",
            @"720p only via verified legacy hardware/hybrid path", @"h264720Policy",
            nil];
}
@end
