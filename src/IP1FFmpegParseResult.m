#import "IP1FFmpegParseResult.h"
#import "IP1MediaInfo.h"
#import "IP1ParseDiagnostics.h"

@implementation IP1FFmpegParseResult
@synthesize tracks = _tracks;
@synthesize chapters = _chapters;
@synthesize mediaInfo = _mediaInfo;
@synthesize diagnostics = _diagnostics;

- (void)dealloc {
    [_tracks release];
    [_chapters release];
    [_mediaInfo release];
    [_diagnostics release];
    [super dealloc];
}
@end
