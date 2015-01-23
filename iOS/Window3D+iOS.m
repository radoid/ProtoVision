//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Window3D+iOS.h"


@implementation Window3D
{
	View3D *_view;
}

- (id)initWithController:(Controller3D *)controller {
	if ((self = [super initWithFrame:[UIScreen mainScreen].bounds])) {
		_view = [[View3D alloc] initWithFrame:self.frame useHighResolution:YES useDepthBuffer:YES];
		[self addSubview:_view];
		[_view pushController:controller];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:NULL];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:NULL];

		//[self makeKeyAndVisible];
	}
	return self;
}

- (void)pushController:(Controller3D *)controller {
	[_view pushController:controller];
}

- (void)applicationDidBecomeActive {
	[_view startAnimation];
}

- (void)applicationWillResignActive {
	[_view stopAnimation];
}

@end
