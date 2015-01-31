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
	}
	return self;
}

- (id)initWithDirection:(Vector3D)direction {
	if ((self = [super init])) {
		_direction = Vector3DUnit(direction);
		_hasDirection = YES;
	}
	return self;
}

- (id)initWithPosition:(Vector3D)position ambient:(Color2D)ambient diffuse:(Color2D)diffuse {
	if ((self = [self initWithPosition:position])) {
		_ambient = ambient;
		_diffuse = diffuse;
	}
	return self;
}

- (id)initWithDirection:(Vector3D)direction ambient:(Color2D)ambient diffuse:(Color2D)diffuse {
	if ((self = [self initWithDirection:direction])) {
		_ambient = ambient;
		_diffuse = diffuse;
	}
	return self;
}

@end
