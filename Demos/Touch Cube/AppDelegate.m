//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "AppDelegate.h"
#import "TouchCubeController.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    _window = [[Window3D alloc] initWithController:[[TouchCubeController alloc] init]];
	
	GLenum err = glGetError(); if (err) NSLog(@"[AppDelegate applicationDidFinishLaunching] Open GL ERROR  = %x", err);

	UIViewController *uiviewcontroller = [[UIViewController alloc] init];
	uiviewcontroller.view = _window.view;
	_window.rootViewController = uiviewcontroller;
	
    [_window makeKeyAndVisible];

	return YES;
}

@end
