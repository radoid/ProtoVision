//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Object2D.h"


@implementation Object2D

@synthesize x, y, scaleX, scaleY, parent, localToWorld, worldToLocal;
@synthesize buffer;

- (id)init {
	if ((self = [super init])) {
		x = y = rotation = 0;
		scaleX = scaleY = 1;
		_color = Color2DMake(1, 1, 1, 1);
		[self recalculate];
	}
	return self;
}

- (id)initWithProgram:(Program3D *)initprogram mode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize colorSize:(int)colorsize isDynamic:(BOOL)dynamic {
	int stride = (vertexsize + texcoordssize + colorsize) * sizeof(GLfloat);
	Buffer3D *buffer = [[Buffer3D alloc] initWithMode:drawmode vertices:vbuffer vertexCount:vcount indices:ibuffer indexCount:icount vertexSize:vertexsize texCoordsSize:texcoordssize normalSize:0 colorSize:colorsize isDynamic:dynamic];
	[buffer setAttribForProgram:initprogram];
	return [self initWithProgram:initprogram buffer:buffer];
}

- (id)initWithMode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize colorSize:(int)colorsize isDynamic:(BOOL)dynamic {
	return [self initWithProgram:[Program3D defaultProgram2D] mode:drawmode vertices:vbuffer vertexCount:vcount indices:ibuffer indexCount:icount vertexSize:vertexsize texCoordsSize:texcoordssize colorSize:colorsize isDynamic:dynamic];
}

- (id)initWithProgram:(Program3D *)initprogram buffer:(Buffer2D *)initbuffer {
	if ((self = [self init])) {
		program = initprogram;
		buffer = initbuffer;
	}
	return self;
}

- (id)initWithBuffer:(Buffer2D *)initbuffer {
	return [self initWithProgram:[Program3D defaultProgram2D] buffer:initbuffer];
}

- (id)copyWithZone:(NSZone *)zone {
	Object2D *copy = [[Object2D allocWithZone:zone] initWithProgram:program buffer:buffer];
	copy.position = self.position;
	copy.scaleX = self.scaleX;
	copy.scaleY = self.scaleY;
	copy.rotation = self.rotation;
	copy.color = self.color;
	return copy;
}

- (void)setX:(float)newx {
	x = newx;
	[self recalculate];
}

- (void)setY:(float)newy {
	y = newy;
	[self recalculate];
}

- (float)scale {
	return (scaleX+scaleY)/2.;
}

- (void)setScale:(float)scale {
	scaleX = scaleY = scale;
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

- (Vector2D)position {
	return Vector2DMake(x, y);
}

- (void)setPosition:(Vector2D)newposition {
	x = newposition.x;
	y = newposition.y;
	[self recalculate];
}

- (float)rotation {
	return rotation;
}

- (void)setRotation:(float)newrotation {
	rotation = newrotation;
	[self recalculate];
}

- (float)opacity {
	return _color.alpha;
}

- (void)setOpacity:(float)newopacity {
	_color.alpha = newopacity;
}

- (void)recalculate {
	localToWorld = (parent ? [parent localToWorld] : Matrix4x4Identity);
	localToWorld = Matrix4x4Translate(localToWorld, x, y, 0);
	if (rotation)
		localToWorld = Matrix4x4Rotate(localToWorld, rotation, 0, 0, 1);
	if (scaleX != 1 || scaleY != 1)
		localToWorld = Matrix4x4Scale(localToWorld, scaleX, scaleY, 1);
	if (_origin.x || _origin.y)
		localToWorld = Matrix4x4Translate(localToWorld, -_origin.x, -_origin.y, 0);
	worldToLocal = Matrix4x4Invert(localToWorld);
}

- (void)drawWithCamera:(Camera2D *)camera {
	Matrix4x4 modelview = Matrix4x4Multiply(camera.worldToLocal, localToWorld);

	if (_color.alpha < 1)
		glEnable(GL_BLEND);

	[program useWithProjection:camera.projection modelView:modelview color:_color texture:texture];
	[buffer draw];

	if (_color.alpha < 1)
		glDisable(GL_BLEND);
}

@end
