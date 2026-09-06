#import <Foundation/Foundation.h>

@interface IP1AudioRuntimeProfile : NSObject
+ (NSUInteger)pcmBufferBytes;
+ (NSUInteger)maximumAudioChannels;
+ (NSUInteger)preferredOutputChannels;
+ (double)preferredSampleRate;
+ (BOOL)decodeSelectedTrackOnly;
+ (BOOL)allowAC3ByDefault;
+ (BOOL)allowEAC3ByDefault;
@end
