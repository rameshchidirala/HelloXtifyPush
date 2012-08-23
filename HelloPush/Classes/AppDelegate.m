#import "AppDelegate.h"
#import "MainViewController.h"
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVURLProtocol.h>
#import "XLappMgr.h"

@implementation AppDelegate
@synthesize window, viewController, invokeString, launchNotification;
- (id) init
{
    /** If you need to do any extra app-specific initialization, you can do it here
     *  -jm
     **/
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    [CDVURLProtocol registerURLProtocol];
    
    if (self = [super init]) {
        XLXtifyOptions *anXtifyOptions=[XLXtifyOptions getXtifyOptions];
        [[XLappMgr get] initilizeXoptions:anXtifyOptions];
    }
    return self;
    // return [super init];
}
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
    NSLog(@"Succeeded registering for push notifications. Device token: %@", devToken);
    [[XLappMgr get] registerWithXtify:devToken ];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)pushMessage
{
    NSLog(@"Receiving notification");
    [[XLappMgr get] appReceiveNotification:pushMessage];
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"Application is about to Enter Background");
    [[XLappMgr get] appEnterBackground];
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"Application moved from inactive to Active state");
    [[XLappMgr get] appEnterActive];
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"Application moved to Foreground");
    [[XLappMgr get] appEnterForeground];
}
-(void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"applicationWillTerminate");
    [[XLappMgr get] applicationWillTerminate];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error
{
    NSLog(@"Failed to register with error: %@", error);
    [[XLappMgr get] registerWithXtify:nil ];
}
#pragma UIApplicationDelegate implementation
/**
 * This is main kick off after the app inits, the views and Settings are setup here. (preferred - iOS4 and up)
 */
- (BOOL) application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    NSURL* url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    NSString* invokedString = nil;
    
    if (url && [url isKindOfClass:[NSURL class]]) {
        invokedString = [url absoluteString];
        NSLog(@"FLD launchOptions = %@", url);
    }
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.window = [[[UIWindow alloc] initWithFrame:screenBounds] autorelease];
    self.window.autoresizesSubviews = YES;
    
    CGRect viewBounds = [[UIScreen mainScreen] applicationFrame];
    
    self.viewController = [[[MainViewController alloc] init] autorelease];
    self.viewController.useSplashScreen = YES;
    self.viewController.wwwFolderName = @"www";
    self.viewController.startPage = @"index.html";
    self.viewController.invokeString = invokedString;
    self.viewController.view.frame = viewBounds;
    
    // check whether the current orientation is supported: if it is, keep it, rather than forcing a rotation
    BOOL forceStartupRotation = YES;
    UIDeviceOrientation curDevOrientation = [[UIDevice currentDevice] orientation];
    
    if (UIDeviceOrientationUnknown == curDevOrientation) {
        // UIDevice isn't firing orientation notifications yet… go look at the status bar
        curDevOrientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    }
    
    if (UIDeviceOrientationIsValidInterfaceOrientation(curDevOrientation)) {
        for (NSNumber *orient in self.viewController.supportedOrientations) {
            if ([orient intValue] == curDevOrientation) {
                forceStartupRotation = NO;
                break;
            }
        }
    }
    
    if (forceStartupRotation) {
        NSLog(@"supportedOrientations: %@", self.viewController.supportedOrientations);
        // The first item in the supportedOrientations array is the start orientation (guaranteed to be at least Portrait)
        UIInterfaceOrientation newOrient = [[self.viewController.supportedOrientations objectAtIndex:0] intValue];
        NSLog(@"AppDelegate forcing status bar to: %d from: %d", newOrient, curDevOrientation);
        [[UIApplication sharedApplication] setStatusBarOrientation:newOrient];
    }
    
    [self.window addSubview:self.viewController.view];
    [self.window makeKeyAndVisible];
    
    [[XLappMgr get] launchWithOptions:application andOptions:launchOptions];
    
    return YES;
}
// this happens while we are running ( in the background, or from within our own app )
// only valid if FLD-Info.plist specifies a protocol to handle
- (BOOL) application:(UIApplication*)application handleOpenURL:(NSURL*)url
{
    if (!url) {
        return NO;
    }
    
    // calls into javascript global function 'handleOpenURL'
    NSString* jsString = [NSString stringWithFormat:@"handleOpenURL(\"%@\");", url];
    [self.viewController.webView stringByEvaluatingJavaScriptFromString:jsString];
    
    // all plugins will get the notification, and their handlers will be called
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification object:url]];
    
    return YES;
}
- (void) dealloc
{
    [super dealloc];
}
@end