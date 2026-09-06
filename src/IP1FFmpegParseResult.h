#import <Foundation/Foundation.h>
@class IP1MediaInfo;
@class IP1ParseDiagnostics;

@interface IP1FFmpegParseResult : NSObject {
@private
    NSArray *_tracks;
    NSArray *_chapters;
    IP1MediaInfo *_mediaInfo;
    IP1ParseDiagnostics *_diagnostics;
}
@property(nonatomic, retain) NSArray *tracks;
@property(nonatomic, retain) NSArray *chapters;
@property(nonatomic, retain) IP1MediaInfo *mediaInfo;
@property(nonatomic, retain) IP1ParseDiagnostics *diagnostics;
@end
