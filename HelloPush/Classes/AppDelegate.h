
#import <UIKit/UIKit.h>
#import <Cordova/CDVViewController.h>


@class XLappMgr; // Xtify Application Manager-include it in your app

@interface AppDelegate : NSObject < UIApplicationDelegate, UIWebViewDelegate, CDVCommandDelegate > {
    NSString* invokeString;
    NSDictionary *launchNotification;
}
- (void) redirectConsoleLogToDocumentFolder;
// invoke string is passed to your app on launch, this is only valid if you
// edit testxtifycordova-Info.plist to add a protocol
// a simple tutorial can be found here :
// http://iphonedevelopertips.com/cocoa/launching-your-own-application-via-a-custom-url-scheme.html

@property (nonatomic, retain) IBOutlet UIWindow* window;
@property (nonatomic, retain) IBOutlet CDVViewController* viewController;
@property (copy)  NSString* invokeString;
@property (nonatomic, retain) NSDictionary *launchNotification;

@end