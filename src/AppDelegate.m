#import "AppDelegate.h"
#import "IP1PlayerViewController.h"

@implementation AppDelegate
@synthesize window = _window;
@synthesize playerViewController = _playerViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.playerViewController = [[[IP1PlayerViewController alloc] init] autorelease];
    self.window.rootViewController = self.playerViewController;
    [self.window makeKeyAndVisible];

    NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if (url) [self.playerViewController openExternalURL:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.playerViewController openExternalURL:url];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    (void)application;
    [self.playerViewController savePlaybackStateForBackground];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    (void)application;
    [self.playerViewController savePlaybackStateForBackground];
}

- (void)dealloc {
    [_playerViewController release];
    [_window release];
    [super dealloc];
}
@end
