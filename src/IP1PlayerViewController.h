#import <UIKit/UIKit.h>
@class MPMoviePlayerController;

@interface IP1PlayerViewController : UIViewController <UIActionSheetDelegate>
- (BOOL)openExternalURL:(NSURL *)url;
- (void)setSleepTimerMinutes:(NSInteger)minutes;
- (void)savePlaybackStateForBackground;
@end
