//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Object3D.h"


@implementation Object3D

- (id)init {
	if ((self = [super init])) {
		_rotation = Quaternion3DZero;
		_scaleX = _scaleY = _scaleZ = 1;
		[self recalculate];
	}
	return self;
}

- (id)initWithPosition:(Vector3D)position direction:(Vector3D)forward up:(Vector3D)up {
	if ((self = [self init])) {
		[self setPosition:position direction:forward up:up];
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	Object3D *copy = (Object3D *) [[[self class] allocWithZone:zone] init];
	copy.position = self.position;
	copy.scaleX = _scaleX;
	copy.scaleY = _scaleY;
	copy.scaleZ = _scaleZ;
	copy.rotation = _rotation;
	return copy;
}

- (Vector3D)position {
	return Vector3DMake(_x, _y, _z);
}

- (void)setPosition:(Vector3D)position {
	_x = position.x;
	_y = position.y;
	_z = position.z;
	[self recalculate];
}

- (void)setX:(float)x {
	_x = x;
	[self recalculate];
}

- (void)setY:(float)y {
	_y = y;
	[self recalculate];
}

- (void)setZ:(float)z {
	_z = z;
	[self recalculate];
}

- (float)scale {
	return (_scaleX+ _scaleY + _scaleZ)/3;
}

- (void)setScale:(float)scale {
	_scaleX = scale;
	_scaleY = scale;
	_scaleZ = scale;
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

- (void)setScaleZ:(float)z {
	_scaleZ = z;
	[self recalculate];
}

- (Vector3D)forward {
	return Vector3DRotateByQuaternion(Vector3DZFlip, _rotation);
}

- (Vector3D)up {
	return Vector3DRotateByQuaternion(Vector3DY, _rotation);
}

- (Vector3D)right {
	return Vector3DRotateByQuaternion(Vector3DX, _rotation);
}

- (void)setRotation:(Quaternion3D)rotation {
	_rotation = rotation;
	_rotationAxis = Quaternion3DAxis(_rotation);
	_rotationAngle = Quaternion3DAngle(_rotation);
	[self recalculate];
}

- (void)rotateByAxis:(Vector3D)axis angle:(float)angle {
	self.rotation = Quaternion3DMultiply(Quaternion3DMakeWithAxisAngle(axis, angle), _rotation);
}

- (void)rotateByQuaternion:(Quaternion3D)q {
	self.rotation = Quaternion3DMultiply(q, _rotation);
}

- (void)rotateAround:(Vector3D)point byQuaternion:(Quaternion3D)q {
	self.position = Vector3DAdd(point, Vector3DRotateByQuaternion(Vector3DSubtract(self.position, point), q));
	self.rotation = Quaternion3DMultiply(q, _rotation);
}

- (void)rotateAround:(Vector3D)point byAxis:(Vector3D)axis angle:(float)angle {
	[self rotateAround:point byQuaternion:Quaternion3DMakeWithAxisAngle(axis, angle)];
}

- (void)directTo:(Vector3D)forward up:(Vector3D)up {
	up = Vector3DCross(forward, Vector3DCross(up, forward));
	Vector3D right = Vector3DCross(forward, up);
	self.rotation = Quaternion3DMakeWithThreeVectors(right, up, Vector3DFlip(forward));
}

- (void)lookAt:(Vector3D)center up:(Vector3D)up {
	Vector3D forward = Vector3DSubtract(center, self.position);
	[self directTo:forward up:up];
}

- (void)setPosition:(Vector3D)position direction:(Vector3D)forward up:(Vector3D)up {
	_x = position.x;
	_y = position.y;
	_z = position.z;
	[self directTo:forward up:up];
}

- (void)setPosition:(Vector3D)position lookAt:(Vector3D)center up:(Vector3D)up {
	[self setPosition:position direction:Vector3DSubtract(center, position) up:up];
}

- (void)addTo:(Container3D *)parent {
	[parent add:self];
}

- (void)removeFromParent {
	[_parent remove:self];
}

- (void)recalculate {
	_localToWorld = (_parent ? _parent.localToWorld : Matrix4x4Identity);
	_localToWorld = Matrix4x4Translate(_localToWorld, _x, _y, _z);
	if (_rotationAngle)
		_localToWorld = Matrix4x4Rotate(_localToWorld, _rotationAngle, _rotationAxis.x, _rotationAxis.y, _rotationAxis.z);
	if (_scaleX != 1 || _scaleY != 1 || _scaleZ != 1)
		_localToWorld = Matrix4x4Scale(_localToWorld, _scaleX, _scaleY, _scaleZ);
	//if (origin.x || origin.y || origin.z)
	//	localToWorld = Matrix4x4Translate(localToWorld, -origin.x, -origin.y, -origin.z);
	_worldToLocal = Matrix4x4Invert(_localToWorld);
}

@end
