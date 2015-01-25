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
		x = y = rotation = 0;
		scaleX = scaleY = 1;
		_color = Color2DMake(1, 1, 1, 1);
		[self recalculate];
	}
	return self;
}

- (id)initWithProgram:(Program3D *)initprogram mode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize colorSize:(int)colorsize isDynamic:(BOOL)dynamic {
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

- (float)opacity {
	return _color.alpha;
}

- (void)setOpacity:(float)newopacity {
	_color.alpha = newopacity;
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
