//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Mesh2D.h"


@implementation Mesh2D

- (id)init {
	if ((self = [super init])) {
		_color = Color2DMake(1, 1, 1, 1);
	}
	return self;
}

- (id)initWithProgram:(Program3D *)program mode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize colorSize:(int)colorsize isDynamic:(BOOL)dynamic {
	return [self initWithProgram:program buffer:[[Buffer3D alloc] initWithMode:drawmode vertices:vbuffer vertexCount:vcount indices:ibuffer indexCount:icount vertexSize:vertexsize texCoordsSize:texcoordssize normalSize:0 tangentSize:0 colorSize:colorsize isDynamic:dynamic]];
}

- (id)initWithMode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize colorSize:(int)colorsize isDynamic:(BOOL)dynamic {
	return [self initWithProgram:[Program3D defaultProgram] mode:drawmode vertices:vbuffer vertexCount:vcount indices:ibuffer indexCount:icount vertexSize:vertexsize texCoordsSize:texcoordssize colorSize:colorsize isDynamic:dynamic];
}

- (id)initWithProgram:(Program3D *)program buffer:(Buffer3D *)buffer {
	if ((self = [self init])) {
		_buffer = buffer;
		[self setProgram:program];
	}
	return self;
}

- (id)initWithBuffer:(Buffer3D *)buffer {
	return [self initWithProgram:[Program3D defaultProgram] buffer:buffer];
}

- (id)copyWithZone:(NSZone *)zone {
	Mesh2D *copy = (Mesh2D *) [super copyWithZone:zone];
	copy.buffer = _buffer;
	copy.program = _program;
	copy.color = _color;
	return copy;
}

- (void)setProgram:(Program3D *)program {
	_program = program;
	[_buffer setAttribArraysFromProgram:program];
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
