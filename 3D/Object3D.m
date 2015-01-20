//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Object3D.h"


@implementation Object3D

@synthesize x, y, z, rotation, rotationAxis, rotationAngle, scaleX, scaleY, scaleZ, color, colorDark, colorLight, parent, localToWorld, worldToLocal, texture;

- (id)init {
	if ((self = [super init])) {
		rotation = Quaternion3DZero;
		scaleX = scaleY = scaleZ = 1;
		color = Color2DMake(1, 1, 1, 1);  // TODO
		colorDark = Color2DMake(0, 0, 0, 1);
		colorLight = Color2DMake(0, 0, 1, 1);
		[self recalculate];
	}
	return self;
}

- (id)initWithBuffer:(Buffer3D *)initbuffer {
	if ((self = [self init])) {
		buffer = initbuffer;
	}
	return self;
}

- (id)initWithVertices:(Buffer3DVertex *)vertices vertexCount:(int)vcount indices:(GLushort *)indices indexCount:(int)icount {
	return [self initWithBuffer:[[Buffer3D alloc] initWithMode:GL_TRIANGLES vertices:vertices vertexCount:vcount indices:indices indexCount:icount isDynamic:NO]];
}

- (id)copyWithZone:(NSZone *)zone {
	Object3D *copy = [[Object3D allocWithZone:zone] initWithBuffer:buffer];
	copy.position = self.position;
	copy.scaleX = self.scaleX;
	copy.scaleY = self.scaleY;
	copy.scaleZ = self.scaleZ;
	copy.rotation = self.rotation;
	copy.color = self.color;
	copy.colorDark = self.colorDark;
	copy.colorLight = self.colorLight;
	copy.texture = self.texture;
	return copy;
}

- (void)setColor:(Color2D)newcolor {
	color = newcolor;
	colorDark =  Color2DMake(newcolor.r+.03*(newcolor.r < 0.17 ? -1 : +1), newcolor.g, newcolor.b/2., 1);
 	colorLight = Color2DMake(newcolor.r+.03*(newcolor.r < 0.17 ? +1 : -1), newcolor.g, 1-(1-newcolor.b)/2., 1);  // TODO
}

- (float)opacity {
	return color.alpha;  // TODO
}

- (void)setOpacity:(float)opacity {
	color.alpha = opacity;  // TODO
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
	self.rotation = Quaternion3DMakeWithThreeVectors(newright, newup, Vector3DFlip(newforward));  // TODO: normalizacija povjerena
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

- (void)drawWithCamera:(Camera3D *)camera {
	Matrix4x4 modelview = Matrix4x4Multiply(camera.worldToLocal, localToWorld);

	if (color.alpha < 1)
		glEnable(GL_BLEND);

	[buffer drawWithProjection:camera.projection modelView:modelview color:color texture:texture];

	if (color.alpha < 1)
		glDisable(GL_BLEND);
}

- (void)drawWithCamera:(Camera3D *)camera light:(Vector3D)direction {
	Matrix4x4 modelview = Matrix4x4Multiply(camera.worldToLocal, localToWorld);
	Matrix3x3 normal = Matrix3x3Transpose(Matrix4x4Invert3x3(localToWorld));

	if (color.alpha < 1 || colorDark.alpha < 1 || colorLight.alpha < 1)
		glEnable(GL_BLEND);

	[buffer drawWithProjection:camera.projection
					 modelView:modelview
						normal:normal
					 colorDark:colorDark
					colorLight:colorLight
					   texture:texture
						 light:direction
					  position:camera.position];

	if (color.alpha < 1 || colorDark.alpha < 1 || colorLight.alpha < 1)
		glDisable(GL_BLEND);
}

@end
