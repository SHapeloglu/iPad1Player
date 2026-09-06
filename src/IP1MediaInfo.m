#import "IP1MediaInfo.h"

@implementation IP1MediaInfo
@synthesize container = _container;
@synthesize videoCodec = _videoCodec;
@synthesize audioCodec = _audioCodec;
@synthesize width = _width;
@synthesize height = _height;
@synthesize fps = _fps;
@synthesize bitrate = _bitrate;
@synthesize sampleRate = _sampleRate;
@synthesize channels = _channels;
@synthesize duration = _duration;

- (NSDictionary *)dictionaryRepresentation {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            (_container ?: @""), @"container",
            (_videoCodec ?: @""), @"videoCodec",
            (_audioCodec ?: @""), @"audioCodec",
            [NSNumber numberWithInteger:_width], @"width",
            [NSNumber numberWithInteger:_height], @"height",
            [NSNumber numberWithDouble:_fps], @"fps",
            [NSNumber numberWithLongLong:_bitrate], @"bitrate",
            [NSNumber numberWithDouble:_sampleRate], @"sampleRate",
            [NSNumber numberWithInteger:_channels], @"channels",
            [NSNumber numberWithDouble:_duration], @"duration",
            nil];
}

- (void)dealloc {
    [_container release];
    [_videoCodec release];
    [_audioCodec release];
    [super dealloc];
}
@end
