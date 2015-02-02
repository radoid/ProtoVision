//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Controller3D+OSX.h"


@implementation Controller3D

- (void)start {}
- (void)stop {}
- (void)resume {}
- (void)resumeWithObject:(id)result {}
- (BOOL)update:(float)delta {return NO;}

- (void)reshape {}

- (void)draw {}

- (void)pushController:(Controller3D *)controller {
	[_view pushController:controller];
}
- (void)popWithObject:(NSObject *)result {
	[_view popWithObject:result];
}

- (BOOL)touchDown:(Vector2D)location modifiers:(int)flags {return NO;}
- (BOOL)touchMove:(Vector2D)location modifiers:(int)flags {return NO;}
- (BOOL)touchUp:(Vector2D)location modifiers:(int)flags {return NO;}

- (BOOL)keyDown:(int)keyCode modifiers:(int)flags {
	if (keyCode == 53)  // Escape
		[NSApp terminate:self];
	return NO;
}
- (BOOL)keyUp:(int)keyCode modifiers:(int)flags {return NO;}
- (BOOL)keyPress:(NSString *)key modifiers:(int)flags {return NO;}

- (int)run {
	[[NSApplication sharedApplication] setDelegate:self];
	[[NSApplication sharedApplication] run];
	return 0;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	_window = [[Window3D alloc] initWithFullScreen];
	[_window.view pushController:self];
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification {
	[_window.view startAnimation];
}

- (void)applicationDidResignActive:(NSNotification *)aNotification {
	[_window.view stopAnimation];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}

@end