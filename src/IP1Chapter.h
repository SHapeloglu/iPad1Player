#import <Foundation/Foundation.h>

@interface IP1Chapter : NSObject {
@private
    NSTimeInterval _startTime;
    NSString *_title;
}
@property(nonatomic, assign) NSTimeInterval startTime;
@property(nonatomic, retain) NSString *title;
@end
