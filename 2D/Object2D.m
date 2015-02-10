//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Object2D.h"


@implementation Object2D

- (id)init {
	if ((self = [super init])) {
		_x = _y = _rotation = 0;
		_scaleX = _scaleY = 1;
		[self recalculate];
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	Object2D *copy = (Object2D *) [[[self class] allocWithZone:zone] init];
	copy.position = self.position;
	copy.scaleX = _scaleX;
	copy.scaleY = _scaleY;
	copy.rotation = _rotation;
	return copy;
}

- (void)setX:(float)x {
	_x = x;
	[self recalculate];
}

- (void)setY:(float)y {
	_y = y;
	[self recalculate];
}

- (float)scale {
	return (_scaleX + _scaleY)/2.f;
}

- (void)setScale:(float)scale {
	_scaleX = _scaleY = scale;
	[self recalculate];
}

- (void)setScaleX:(float)x {
	_scaleX = x;
	[self recalculate];
}

- (void)setScaleY:(float)y {
	_scaleY = y;
	[self recalculate];
}

- (Vector2D)position {
	return Vector2DMake(_x, _y);
}

- (void)setPosition:(Vector2D)position {
	_x = position.x;
	_y = position.y;
	[self recalculate];
}

- (float)rotation {
	return _rotation;
}

- (void)setRotation:(float)rotation {
	_rotation = rotation;
	[self recalculate];
}

- (void)recalculate {
	_localToWorld = (_parent ? [_parent localToWorld] : Matrix4x4Identity);
	_localToWorld = Matrix4x4Translate(_localToWorld, _x, _y, 0);
	if (_rotation)
		_localToWorld = Matrix4x4Rotate(_localToWorld, _rotation, 0, 0, 1);
	if (_scaleX != 1 || _scaleY != 1)
		_localToWorld = Matrix4x4Scale(_localToWorld, _scaleX, _scaleY, 1);
	if (_origin.x || _origin.y)
		_localToWorld = Matrix4x4Translate(_localToWorld, -_origin.x, -_origin.y, 0);
	_worldToLocal = Matrix4x4Invert(_localToWorld);
}

@end
