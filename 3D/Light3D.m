//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Light3D.h"


@implementation Light3D

- (id)initWithPosition:(Vector3D)position {
	if ((self = [super init])) {
		_position = position;
		_hasPosition = YES;
		_color = Color2DMake(1, 1, 1, 1);
	}
	return self;
}

- (id)initWithDirection:(Vector3D)direction {
	if ((self = [super init])) {
		_direction = Vector3DUnit(direction);
		_hasDirection = YES;
		_color = Color2DMake(1, 1, 1, 1);
	}
	return self;
}

- (id)initWithPosition:(Vector3D)position color:(Color2D)color {
	if ((self = [self initWithPosition:position])) {
		_color = color;
	}
	return self;
}

- (id)initWithDirection:(Vector3D)direction color:(Color2D)color {
	if ((self = [self initWithDirection:direction])) {
		_color = color;
	}
	return self;
}

@end
