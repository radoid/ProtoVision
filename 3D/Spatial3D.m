//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Spatial3D.h"


@implementation Spatial3D

@synthesize x, y, z, rotation, rotationAxis, rotationAngle, scaleX, scaleY, scaleZ, parent, localToWorld, worldToLocal;

- (id)init {
	if ((self = [super init])) {
		rotation = Quaternion3DZero;
		scaleX = scaleY = scaleZ = 1;
		[self recalculate];
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	Spatial3D *copy = [[Spatial3D allocWithZone:zone] init];
	copy.position = self.position;
	copy.scaleX = self.scaleX;
	copy.scaleY = self.scaleY;
	copy.scaleZ = self.scaleZ;
	copy.rotation = self.rotation;
	return copy;
}

- (Vector3D)position {
	return Vector3DMake(x, y, z);
}

- (void)setPosition:(Vector3D)position {
	x = position.x;
	y = position.y;
	z = position.z;
	[self recalculate];
}

- (void)setX:(float)newx {
	x = newx;
	[self recalculate];
}

- (void)setY:(float)newy {
	y = newy;
	[self recalculate];
}

- (void)setZ:(float)newz {
	z = newz;
	[self recalculate];
}

- (float)scale {
	return (scaleX+scaleY+scaleZ)/3;
}

- (void)setScale:(float)newscale {
	scaleX = newscale;
	scaleY = newscale;
	scaleZ = newscale;
	[self recalculate];
}

- (void)setScaleX:(float)newx {
	scaleX = newx;
	[self recalculate];
}

- (void)setScaleY:(float)newy {
	scaleY = newy;
	[self recalculate];
}

- (void)setScaleZ:(float)newz {
	scaleZ = newz;
	[self recalculate];
}

- (Vector3D)forward {
	return Vector3DRotateByQuaternion(Vector3DZFlip, rotation);
}

- (Vector3D)up {
	return Vector3DRotateByQuaternion(Vector3DY, rotation);
}

- (Vector3D)right {
	return Vector3DRotateByQuaternion(Vector3DX, rotation);
}

- (void)setRotation:(Quaternion3D)newrotation {
	rotation = newrotation;
	rotationAxis = Quaternion3DAxis(rotation);
	rotationAngle = Quaternion3DAngle(rotation);
	[self recalculate];
}

- (void)rotateByAxis:(Vector3D)axis angle:(float)angle {
	self.rotation = Quaternion3DMultiply(Quaternion3DMakeWithAxisAngle(axis, angle), rotation);
}

- (void)rotateByQuaternion:(Quaternion3D)q {
	self.rotation = Quaternion3DMultiply(q, rotation);
}

- (void)rotateAround:(Vector3D)point byQuaternion:(Quaternion3D)q {
	self.position = Vector3DAdd(point, Vector3DRotateByQuaternion(Vector3DSubtract(self.position, point), q));
	self.rotation = Quaternion3DMultiply(q, rotation);
}

- (void)directTo:(Vector3D)newforward up:(Vector3D)newup {
	newup = Vector3DCross(newforward, Vector3DCross(newup, newforward));
	Vector3D newright = Vector3DCross(newforward, newup);
	self.rotation = Quaternion3DMakeWithThreeVectors(newright, newup, Vector3DFlip(newforward));
}

- (void)lookAt:(Vector3D)center up:(Vector3D)newup {
	Vector3D newforward = Vector3DSubtract(center, self.position);
	[self directTo:newforward up:newup];
}

- (void)setPosition:(Vector3D)position lookAt:(Vector3D)center up:(Vector3D)newup {
	x = position.x;
	y = position.y;
	z = position.z;
	Vector3D newforward = Vector3DSubtract(center, self.position);
	[self directTo:newforward up:newup];
}

- (void)recalculate {
	localToWorld = (parent ? parent.localToWorld : Matrix4x4Identity);
	localToWorld = Matrix4x4Translate(localToWorld, x, y, z);
	if (rotationAngle)
		localToWorld = Matrix4x4Rotate(localToWorld, rotationAngle, rotationAxis.x, rotationAxis.y, rotationAxis.z);
	if (scaleX != 1 || scaleY != 1 || scaleZ != 1)
		localToWorld = Matrix4x4Scale(localToWorld, scaleX, scaleY, scaleZ);
	//if (origin.x || origin.y || origin.z)
	//	localToWorld = Matrix4x4Translate(localToWorld, -origin.x, -origin.y, -origin.z);
	worldToLocal = Matrix4x4Invert(localToWorld);
}

@end
