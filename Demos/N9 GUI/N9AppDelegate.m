#import "N9AppDelegate.h"
#import "N9Controller.h"


@implementation N9AppDelegate

@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	NSLog(@"[AppDelegate didFinishLaunchingWithOptions]");

	glView = [[View3D alloc] initWithFrame:[window frame] useHighResolution:YES useDepthBuffer:NO];
	[window addSubview:glView];
	[window makeKeyAndVisible];
	
	[glView pushController:[[[N9Controller alloc] init] autorelease]];

	GLenum err = glGetError(); if (err) NSLog(@"GL ERROR applicationDidFinishLaunching0 = %x", err);

	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
	NSLog(@"[AppDelegate applicationWillResignActive]");
	[glView stop];
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	NSLog(@"[AppDelegate applicationDidBecomeActive]");
	[glView start];
	
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[window release];
	[glView release];
	[super dealloc];
}


@end