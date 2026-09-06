#import "IP1ParseDiagnostics.h"
#import "IP1ParseResultValidator.h"
#import "IP1FFmpegParseResult.h"
#import "IP1ParsePolicy.h"
#import "IP1MediaInfo.h"

@implementation IP1ParseResultValidator

+ (BOOL)validateResult:(IP1FFmpegParseResult *)result error:(NSString **)errorMessage {
    if (!result) {
        if (errorMessage) *errorMessage = @"Parse sonucu boş.";
        return NO;
    }

    if ([IP1ParsePolicy shouldRejectTrackCount:[result.tracks count]
                                 chapterCount:[result.chapters count]]) {
        if (errorMessage) *errorMessage = @"Track/chapter limiti aşıldı.";
        return NO;
    }


    if (result.mediaInfo.width < 0 || result.mediaInfo.height < 0 ||
        result.mediaInfo.width > 4096 || result.mediaInfo.height > 4096) {
        if (errorMessage) *errorMessage = @"Geçersiz veya aşırı video boyutu metadata bilgisi.";
        return NO;
    }

    if (result.mediaInfo.fps < 0.0 || result.mediaInfo.fps > 120.0) {
        if (errorMessage) *errorMessage = @"Geçersiz FPS metadata bilgisi.";
        return NO;
    }

    if (result.mediaInfo.sampleRate < 0.0 || result.mediaInfo.sampleRate > 192000.0) {
        if (errorMessage) *errorMessage = @"Geçersiz audio sample-rate metadata bilgisi.";
        return NO;
    }

    if (result.mediaInfo.channels < 0 || result.mediaInfo.channels > 16) {
        if (errorMessage) *errorMessage = @"Geçersiz audio kanal metadata bilgisi.";
        return NO;
    }

    if (result.mediaInfo.duration > [IP1ParsePolicy maximumMediaDurationSeconds]) {
        if (errorMessage) *errorMessage = @"Medya süresi güvenlik limitini aşıyor.";
        return NO;
    }

    if (result.diagnostics && !result.diagnostics.withinLimits) {
        if (errorMessage) *errorMessage = (result.diagnostics.message ?: @"Parse limitleri aşıldı.");
        return NO;
    }

    return YES;
}
@end
