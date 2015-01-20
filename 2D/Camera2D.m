//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "Camera2D.h"


@implementation Camera2D

@synthesize frame, orientation, projection;

- (id)initWithFrame:(CGRect)initframe {
	return [self initWithFrame:initframe near:-initframe.size.width far:initframe.size.width];
}

- (id)initWithFrame:(CGRect)initcoords near:(float)initnear far:(float)initfar {
	if ((self = [super init])) {
		near = initnear;
		far = initfar;
		[self setFrame:initcoords];
	}
	return self;
}

- (void)setFrame:(CGRect)newframe {
	coords = newframe;
	[self recalculate];
}

- (void)setOrientation:(float)neworientation {
	rotation = orientation = neworientation;
	if (orientation == -90) {  // TODO
		x = 0;
		y = frame.size.width;
	} else if (orientation == +90) {
		x = frame.size.height;
		y = 0;
	} else if (orientation == 180) {
		x = frame.size.width;
		y = frame.size.height;
	}
	[self recalculate];
}

- (void)recalculate {
	[super recalculate];
	//if (orientationAngle)
	//	localToWorld = Matrix4x4Rotate(localToWorld, orientationAngle, 0, 0, 1);
	//worldToLocal = Matrix4x4Invert(localToWorld);
	projection = Matrix4x4Ortho(coords.origin.x, coords.origin.x + coords.size.width, coords.origin.y, coords.origin.y + coords.size.height, near, far);
}

@end
