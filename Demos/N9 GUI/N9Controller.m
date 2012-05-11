#import "N9Controller.h"


@implementation N9Controller

- (id)init {
	if ((self = [super init])) {
		[Texture2D loadImageMap:@"n9" withImageNamed:@"n9-atlas"];
		CGRect appframe = [[UIScreen mainScreen] applicationFrame];
		appframe.origin.y = 0;
		Image2D *background = [[[Image2D alloc] initWithImageNamed:@"window" origin:CGPointZero frame:appframe stretch:CGRectMake(5, 5, -5, -37)] autorelease];
		Image2D *button = [[[Image2D alloc] initWithImageNamed:@"button" origin:CGPointZero frame:CGRectMake(10, 290, 80, 25) stretch:CGRectMake(9, 9, -9, -9)] autorelease];
		button.y = appframe.size.height - button.height/2 - 36/2;
		[stage add:background];
		[stage add:button];
	}
	return self;
}

- (void)dealloc {
	[Texture2D unloadAll];
	[super dealloc];
}
	
@end
