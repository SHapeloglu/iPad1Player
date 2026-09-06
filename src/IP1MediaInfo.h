#import <Foundation/Foundation.h>

@interface IP1MediaInfo : NSObject {
@private
    NSString *_container;
    NSString *_videoCodec;
    NSString *_audioCodec;
    NSInteger _width;
    NSInteger _height;
    double _fps;
    long long _bitrate;
    double _sampleRate;
    NSInteger _channels;
    NSTimeInterval _duration;
}
@property(nonatomic, retain) NSString *container;
@property(nonatomic, retain) NSString *videoCodec;
@property(nonatomic, retain) NSString *audioCodec;
@property(nonatomic, assign) NSInteger width;
@property(nonatomic, assign) NSInteger height;
@property(nonatomic, assign) double fps;
@property(nonatomic, assign) long long bitrate;
@property(nonatomic, assign) double sampleRate;
@property(nonatomic, assign) NSInteger channels;
@property(nonatomic, assign) NSTimeInterval duration;
- (NSDictionary *)dictionaryRepresentation;
@end
