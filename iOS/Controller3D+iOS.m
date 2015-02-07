//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Controller3D+iOS.h"


@implementation Controller3D
{
	BOOL _animated;
}

- (void)start {}
- (void)stop {}
- (void)resume {}
- (void)resumeWithObject:(id)result {}
- (BOOL)update:(float)delta {return NO;}

- (BOOL)touchDown:(Vector2D)location {return NO;}
- (BOOL)touchMove:(Vector2D)location {return NO;}
- (BOOL)touchUp:(Vector2D)location {return NO;}

- (void)reshape {}

- (void)draw {}

- (void)pushController:(Controller3D *)controller {
	[_view pushController:controller];
}
- (void)popWithObject:(NSObject *)result {
	[_view popWithObject:result];
}

- (int)run {
	@autoreleasepool {
		return UIApplicationMain(0, nil, nil, NSStringFromClass([self class]));
	}
}

- (int)runAnimated {
	_animated = YES;
	return [self run];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	_window = [[Window3D alloc] initWithController:self];
	UIViewController *uiviewcontroller = [[UIViewController alloc] init];
	uiviewcontroller.view = _window.view;
	_window.rootViewController = uiviewcontroller;
	[_window makeKeyAndVisible];
	//[_window.view pushController:self];
	return YES;
}
/*
- (void)applicationDidBecomeActive:(NSNotification *)aNotification {
	if (_animated)
		[_window.view startAnimation];
}

- (void)applicationDidResignActive:(NSNotification *)aNotification {
	if (_animated)
		[_window.view stopAnimation];
}
*/
@end
