//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "AppDelegate.h"
#import "SpinningCubeController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[_window.view pushController:[[SpinningCubeController alloc] init]];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
	[_window.view startAnimation];
}

- (void)applicationDidResignActive:(NSNotification *)notification {
	[_window.view stopAnimation];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}

@end
