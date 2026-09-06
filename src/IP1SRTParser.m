#import "IP1SRTParser.h"
#import "IP1SubtitleCue.h"

@implementation IP1SRTParser

+ (NSTimeInterval)timeFromSRTString:(NSString *)s {
    NSArray *parts = [s componentsSeparatedByString:@":"];
    if ([parts count] != 3) return -1;
    NSString *tail = [[parts objectAtIndex:2] stringByReplacingOccurrencesOfString:@"." withString:@","];
    NSArray *secParts = [tail componentsSeparatedByString:@","];
    if ([secParts count] != 2) return -1;
    NSInteger h = [[parts objectAtIndex:0] integerValue];
    NSInteger m = [[parts objectAtIndex:1] integerValue];
    NSInteger sec = [[secParts objectAtIndex:0] integerValue];
    NSInteger ms = [[secParts objectAtIndex:1] integerValue];
    return h * 3600.0 + m * 60.0 + sec + (ms / 1000.0);
}

+ (NSStringEncoding)nsEncodingForChoice:(IP1SubtitleEncoding)choice {
    switch (choice) {
        case IP1SubtitleEncodingWindows1254:
            return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingWindowsLatin5);
        case IP1SubtitleEncodingISO88599:
            return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin5);
        case IP1SubtitleEncodingUTF8:
        default:
            return NSUTF8StringEncoding;
    }
}

+ (NSString *)displayNameForEncoding:(IP1SubtitleEncoding)encoding {
    switch (encoding) {
        case IP1SubtitleEncodingUTF8: return @"UTF-8";
        case IP1SubtitleEncodingWindows1254: return @"Windows-1254";
        case IP1SubtitleEncodingISO88599: return @"ISO-8859-9";
        default: return @"Otomatik";
    }
}

+ (NSString *)stringAtPath:(NSString *)path encoding:(IP1SubtitleEncoding)choice error:(NSError **)error {
    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:error];
    if (!data) return nil;

    if (choice != IP1SubtitleEncodingAutomatic) {
        NSStringEncoding enc = [self nsEncodingForChoice:choice];
        NSString *forced = [[[NSString alloc] initWithData:data encoding:enc] autorelease];
        if (forced) return forced;
        if (error) *error = [NSError errorWithDomain:@"IP1SRTParser" code:3 userInfo:[NSDictionary dictionaryWithObject:@"Subtitle cannot be decoded with selected encoding." forKey:NSLocalizedDescriptionKey]];
        return nil;
    }

    NSArray *encodings = [NSArray arrayWithObjects:
        [NSNumber numberWithUnsignedInteger:NSUTF8StringEncoding],
        [NSNumber numberWithUnsignedInteger:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingWindowsLatin5)],
        [NSNumber numberWithUnsignedInteger:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin5)], nil];
    for (NSNumber *n in encodings) {
        NSString *s = [[[NSString alloc] initWithData:data encoding:[n unsignedIntegerValue]] autorelease];
        if (s) return s;
    }

    if (error) *error = [NSError errorWithDomain:@"IP1SRTParser" code:2 userInfo:[NSDictionary dictionaryWithObject:@"Subtitle encoding is not UTF-8, Windows-1254 or ISO-8859-9." forKey:NSLocalizedDescriptionKey]];
    return nil;
}

+ (NSArray *)parseSRTAtPath:(NSString *)path error:(NSError **)error {
    return [self parseSRTAtPath:path encoding:IP1SubtitleEncodingAutomatic error:error];
}

+ (NSArray *)parseSRTAtPath:(NSString *)path encoding:(IP1SubtitleEncoding)encoding error:(NSError **)error {
    NSString *content = [self stringAtPath:path encoding:encoding error:error];
    if (!content) return nil;

    content = [content stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
    content = [content stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
    NSArray *blocks = [content componentsSeparatedByString:@"\n\n"];
    NSMutableArray *cues = [NSMutableArray array];

    for (NSString *block in blocks) {
        NSArray *lines = [block componentsSeparatedByString:@"\n"];
        if ([lines count] < 2) continue;
        NSUInteger timingIndex = ([[lines objectAtIndex:0] rangeOfString:@"-->"].location == NSNotFound) ? 1 : 0;
        if (timingIndex >= [lines count]) continue;
        NSArray *times = [[lines objectAtIndex:timingIndex] componentsSeparatedByString:@"-->"];
        if ([times count] != 2) continue;
        NSString *start = [[times objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *end = [[times objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSTimeInterval startTime = [self timeFromSRTString:start];
        NSTimeInterval endTime = [self timeFromSRTString:end];
        if (startTime < 0 || endTime <= startTime) continue;

        NSMutableArray *textLines = [NSMutableArray array];
        for (NSUInteger i = timingIndex + 1; i < [lines count]; i++) {
            NSString *line = [lines objectAtIndex:i];
            if ([line length]) [textLines addObject:line];
        }
        if (![textLines count]) continue;

        IP1SubtitleCue *cue = [[[IP1SubtitleCue alloc] init] autorelease];
        cue.startTime = startTime;
        cue.endTime = endTime;
        cue.text = [textLines componentsJoinedByString:@"\n"];
        [cues addObject:cue];
    }
    return cues;
}
@end
