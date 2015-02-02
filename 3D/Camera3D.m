//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Camera3D.h"


@implementation Camera3D

- (id)initWithPerspectiveFOVY:(float)fovy aspect:(float)aspect near:(float)near far:(float)far {
	if ((self = [super init])) {
		_fovy = fovy;
		_near = near;
		_far = far;
		[self setAspect:aspect];
	}
	return self;
}

- (id)initWithPerspectivePosition:(Vector3D)position lookAt:(Vector3D)center up:(Vector3D)up fovy:(float)fovy aspect:(float)aspect near:(float)near far:(float)far {
	if ((self = [super initWithPosition:position direction:Vector3DSubtract(center, position) up:up])) {
		_near = near;
		_far = far;
		_fovy = fovy;
		[self setAspect:aspect];
	}
	return self;
}

- (id)initWithOrtographicFrame:(CGRect)frame near:(float)near far:(float)far {
	if ((self = [super init])) {
		_fovy = 0;
		_near = near;
 		_far = far;
		[self setFrame: frame];
	}
	return self;
}

- (id)initWithOrtographicPosition:(Vector3D)position lookAt:(Vector3D)center up:(Vector3D)up frame:(CGRect)frame near:(float)near far:(float)far {
	if ((self = [super initWithPosition:position direction:Vector3DSubtract(center, position) up:up])) {
		_fovy = 0;
		_near = near;
 		_far = far;
		[self setFrame: frame];
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	Camera3D *copy = (Camera3D *) [super copyWithZone:zone];
	copy.fovy = _fovy;
	copy.near = _near;
	copy.far = _far;
	copy.orientation = _orientation;
	copy.projection = _projection;
	return copy;
}

- (void)setFrame:(CGRect)frame {
	if (!_fovy)
		_projection = Matrix4x4Ortho(frame.origin.x, frame.origin.x+frame.size.width, frame.origin.y, frame.origin.y+frame.size.height, _near, _far);
}

- (void)setAspect:(float)aspect {
	if (_fovy)
		_projection = Matrix4x4Perspective(_fovy, aspect, _near, _far);
}

- (void)setOrientation:(float)orientation {
	_orientation = orientation;
	[self recalculate];
}

- (void)recalculate {
	[super recalculate];
	if (_orientation) {
		_localToWorld = Matrix4x4Rotate(_localToWorld, _orientation, 0, 0, 1);
		_worldToLocal = Matrix4x4Invert(_localToWorld);
	}
}

- (Vector2D)project:(Vector3D)position to:(CGRect)frame {
	Vector3D projected = Vector3DMultiply(Vector3DMultiply(position, _worldToLocal), _projection);
	return Vector2DMake(frame.origin.x + (projected.x+1) * frame.size.width, frame.origin.x + (projected.y+1) * frame.size.height);
}

- (Ray3D)unproject:(Vector2D)point from:(CGRect)frame {
	Matrix4x4 inverse = Matrix4x4Invert(Matrix4x4Multiply(_projection, _worldToLocal));
	Vector3D normalized = Vector3DMake(2*(point.x-frame.origin.x)/frame.size.width-1, 2*(point.y-frame.origin.y)/frame.size.height-1, _far);
	float h = inverse.data[3]*normalized.x + inverse.data[7]*normalized.y + inverse.data[11]*normalized.z + inverse.data[15];  // TODO division by zero
	Vector3D p1 = Vector3DScale(Vector3DMultiply(normalized, inverse), 1/h);
	normalized.z = _near;
	h = inverse.data[3]*normalized.x + inverse.data[7]*normalized.y + inverse.data[11]*normalized.z + inverse.data[15];
	Vector3D p2 = Vector3DScale(Vector3DMultiply(normalized, inverse), 1/h);
	return Ray3DMake(p1, Vector3DSubtract(p2, p1));
}

@end
