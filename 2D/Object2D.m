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
		_color = Color2DMake(1, 1, 1, 1);
	}
	return self;
}

- (id)initWithProgram:(Program3D *)initprogram mode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize colorSize:(int)colorsize isDynamic:(BOOL)dynamic {
	return [self initWithProgram:initprogram buffer:[[Buffer3D alloc] initWithMode:drawmode vertices:vbuffer vertexCount:vcount indices:ibuffer indexCount:icount vertexSize:vertexsize texCoordsSize:texcoordssize normalSize:0 colorSize:colorsize isDynamic:dynamic]];
}

- (id)initWithMode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize colorSize:(int)colorsize isDynamic:(BOOL)dynamic {
	return [self initWithProgram:[Program3D defaultProgram2D] mode:drawmode vertices:vbuffer vertexCount:vcount indices:ibuffer indexCount:icount vertexSize:vertexsize texCoordsSize:texcoordssize colorSize:colorsize isDynamic:dynamic];
}

- (id)initWithProgram:(Program3D *)initprogram buffer:(Buffer3D *)initbuffer {
	if ((self = [self init])) {
		_buffer = initbuffer;
		[self setProgram:initprogram];
	}
	return self;
}

- (id)initWithBuffer:(Buffer3D *)initbuffer {
	return [self initWithProgram:[Program3D defaultProgram2D] buffer:initbuffer];
}

- (id)copyWithZone:(NSZone *)zone {
	Object2D *copy = (Object2D *) [super copyWithZone:zone];
	copy.buffer = _buffer;
	copy.program = _program;
	copy.color = _color;
	return copy;
}

- (void)setProgram:(Program3D *)initprogram {
	_program = initprogram;
	[_buffer setAttribArraysFromProgram:initprogram];
}

- (float)opacity {
	return _color.alpha;
}

- (void)setOpacity:(float)opacity {
	_color.alpha = opacity;
}

- (void)drawWithCamera:(Camera2D *)camera {
	Matrix4x4 modelview = Matrix4x4Multiply(camera.worldToLocal, _localToWorld);

	//NSLog(@"%@ %@", [self class], _buffer);

	if (_color.alpha < 1)
		glEnable(GL_BLEND);

	[_program useWithProjection:camera.projection modelView:modelview color:_color texture:_texture];
	[_buffer draw];

	if (_color.alpha < 1)
		glDisable(GL_BLEND);
}

@end
