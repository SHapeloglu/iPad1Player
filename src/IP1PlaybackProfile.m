#import "IP1PlaybackProfile.h"

@implementation IP1PlaybackProfile

+ (NSArray *)safePlaybackRates {
    return [NSArray arrayWithObjects:
            [NSNumber numberWithFloat:0.5f],
            [NSNumber numberWithFloat:0.75f],
            [NSNumber numberWithFloat:1.0f],
            [NSNumber numberWithFloat:1.25f],
            [NSNumber numberWithFloat:1.5f],
            nil];
}

+ (BOOL)allowExperimentalTwoX { return NO; }
+ (BOOL)allowSoftware360pH264 { return YES; }
+ (BOOL)allowSoftware480pH264 { return YES; }
+ (BOOL)allowSoftware720pH264PrimaryPath { return NO; }
+ (BOOL)allowModernCodecs { return NO; }

@end
