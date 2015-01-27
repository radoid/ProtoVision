//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "Camera2D.h"


@implementation Camera2D

- (id)initWithFrame:(CGRect)frame {
	return [self initWithFrame:frame near:-frame.size.width far:frame.size.width];
}

- (id)initWithFrame:(CGRect)frame near:(float)near far:(float)far {
	if ((self = [super init])) {
		_near = near;
		_far = far;
		[self setFrame:frame];
	}
	return self;
}

- (void)setFrame:(CGRect)frame {
	_frame = frame;
	[self recalculate];
}

- (void)setOrientation:(float)orientation {
	_rotation = _orientation = orientation;
	if (_orientation == -90) {  // TODO
		_x = 0;
		_y = _frame.size.width;
	} else if (_orientation == +90) {
		_x = _frame.size.height;
		_y = 0;
	} else if (_orientation == 180) {
		_x = _frame.size.width;
		_y = _frame.size.height;
	}
	[self recalculate];
}

- (void)recalculate {
	[super recalculate];
	//if (orientationAngle)
	//	localToWorld = Matrix4x4Rotate(localToWorld, orientationAngle, 0, 0, 1);
	//worldToLocal = Matrix4x4Invert(localToWorld);
	_projection = Matrix4x4Ortho(_frame.origin.x, _frame.origin.x + _frame.size.width, _frame.origin.y, _frame.origin.y + _frame.size.height, _near, _far);
}

@end
