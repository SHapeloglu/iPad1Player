#import "IP1ParseStressTester.h"
#import "IP1MKVBackend.h"
#import "IP1ParseStressResult.h"
#import "IP1FFmpegParseResult.h"

@implementation IP1ParseStressTester

+ (IP1ParseStressResult *)runWithBackend:(IP1MKVBackend *)backend
                                    path:(NSString *)path
                              iterations:(NSUInteger)iterations {
    IP1ParseStressResult *report = [[[IP1ParseStressResult alloc] init] autorelease];

    /* Keep this intentionally small on iPad 1 unless explicitly overridden in a test build. */
    if (iterations == 0) iterations = 10;
    if (iterations > 25) iterations = 25;

    report.iterationsRequested = iterations;
    NSTimeInterval started = [NSDate timeIntervalSinceReferenceDate];

    NSAutoreleasePool *outerPool = [[NSAutoreleasePool alloc] init];
    NSUInteger i;
    for (i = 0; i < iterations; i++) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

        NSString *error = nil;
        IP1FFmpegParseResult *result = [backend parseMetadataAtPath:path error:&error];
        if (!result) {
            report.failures++;
            report.lastError = (error ?: @"Bilinmeyen parse hatası.");
        } else {
            report.iterationsCompleted++;
        }

        [pool drain];

        if (report.failures > 2) break;
    }
    [outerPool drain];

    report.totalElapsedSeconds = [NSDate timeIntervalSinceReferenceDate] - started;
    report.passed = (report.failures == 0 && report.iterationsCompleted == report.iterationsRequested);
    return report;
}

@end
