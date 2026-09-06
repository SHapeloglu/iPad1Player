#import <Foundation/Foundation.h>
#import "IP1H264DecodePolicy.h"

@interface IP1VideoDecodeCapability : NSObject {
@private
    NSString *_codec;
    NSInteger _width;
    NSInteger _height;
    IP1H264DecodeDecision _decision;
    NSString *_reason;
}
@property(nonatomic, retain) NSString *codec;
@property(nonatomic, assign) NSInteger width;
@property(nonatomic, assign) NSInteger height;
@property(nonatomic, assign) IP1H264DecodeDecision decision;
@property(nonatomic, retain) NSString *reason;
- (NSDictionary *)dictionaryRepresentation;
@end
