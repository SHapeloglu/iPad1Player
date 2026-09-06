#import "IP1AudioRuntimeProfile.h"

@implementation IP1AudioRuntimeProfile

+ (NSUInteger)pcmBufferBytes { return 256 * 1024; }
+ (NSUInteger)maximumAudioChannels { return 6; }
+ (NSUInteger)preferredOutputChannels { return 2; }
+ (double)preferredSampleRate { return 44100.0; }
+ (BOOL)decodeSelectedTrackOnly { return YES; }
+ (BOOL)allowAC3ByDefault { return NO; }
+ (BOOL)allowEAC3ByDefault { return NO; }

@end
