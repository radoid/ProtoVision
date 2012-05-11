#import "AppDelegate.h"
#import "RotatingBoxController.h"


@implementation AppDelegate

#pragma mark - Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	NSLog(@"[AppDelegate didFinishLaunchingWithOptions]");

    window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

	view = [[[View3D alloc] initWithFrame:window.frame useHighResolution:YES useDepthBuffer:YES] autorelease];
	[view pushController:[[[RotatingBoxController alloc] init] autorelease]];
	
	GLenum err = glGetError(); if (err) NSLog(@"[AppDelegate applicationDidFinishLaunching] Open GL ERROR  = %x", err);

	[window addSubview:view];
    [window makeKeyAndVisible];

	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
	NSLog(@"[AppDelegate applicationWillResignActive]");
	[view stop];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	NSLog(@"[AppDelegate applicationDidBecomeActive]");
	[view start];
}


- (void)applicationWillTerminate:(UIApplication *)application {
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
}


- (void)dealloc {
	[window release];
	[super dealloc];
}


@end
