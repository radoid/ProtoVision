//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Camera3D.h"


@implementation Camera3D

@synthesize aspect, projection, orientation=orientationAngle;


- (id)initWithPosition:(Vector3D)initposition lookAt:(Vector3D)center up:(Vector3D)up fovy:(float)initfovy aspect:(float)initaspect near:(float)initnear far:(float)initfar {
	if ((self = [super init])) {
		near = initnear;
		far = initfar;
		fovy = initfovy;
		aspect = initaspect;
		[self setPosition: initposition];
		[self lookAt:center up:up];
	}
	return self;
}

- (void)setAspect:(float)initaspect {
	aspect = initaspect;
	[self recalculate];
}

- (void)setOrientation:(float)neworientation {
	orientationAngle = neworientation;
	[self recalculate];
}

- (void)recalculate {
	[super recalculate];
	if (orientationAngle) {
		localToWorld = Matrix4x4Rotate(localToWorld, orientationAngle, 0, 0, 1);
		worldToLocal = Matrix4x4Invert(localToWorld);
	}
	projection = Matrix4x4Perspective(fovy, aspect, near, far);
}

- (Ray3D)unproject:(Vector2D)point from:(CGRect)frame {
	Matrix4x4 inverse = Matrix4x4Invert(Matrix4x4Multiply(projection, worldToLocal));
	Vector3D normalized = Vector3DMake(2*(point.x-frame.origin.x)/frame.size.width-1, 2*(point.y-frame.origin.y)/frame.size.height-1, far);
	float h = inverse.data[3]*normalized.x + inverse.data[7]*normalized.y + inverse.data[11]*normalized.z + inverse.data[15];  // TODO division by zero
	Vector3D p1 = Vector3DScale(Vector3DMultiply(normalized, inverse), 1/h);
	normalized.z = near;
	h = inverse.data[3]*normalized.x + inverse.data[7]*normalized.y + inverse.data[11]*normalized.z + inverse.data[15];
	Vector3D p2 = Vector3DScale(Vector3DMultiply(normalized, inverse), 1/h);
	return Ray3DMake(p1, Vector3DSubtract(p2, p1));
}

@end
