#import <Foundation/Foundation.h>

typedef enum {
    IP1MediaTrackVideo = 0,
    IP1MediaTrackAudio,
    IP1MediaTrackSubtitle
} IP1MediaTrackType;

@interface IP1MediaTrack : NSObject {
@private
    NSInteger _streamIndex;
    IP1MediaTrackType _type;
    NSString *_codecName;
    NSString *_language;
    NSString *_title;
    BOOL _selected;
}
@property(nonatomic, assign) NSInteger streamIndex;
@property(nonatomic, assign) IP1MediaTrackType type;
@property(nonatomic, retain) NSString *codecName;
@property(nonatomic, retain) NSString *language;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, assign) BOOL selected;
@end
