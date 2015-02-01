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
		[self setColor:Color2DMake(1, 0, 1, 1)];
	}
	return self;
}

- (id)initWithProgram:(Program3D *)initprogram buffer:(Buffer3D *)initbuffer {
	if ((self = [self init])) {
		_buffer = initbuffer;
		[self setProgram:initprogram];
	}
	return self;
}

- (id)initWithBuffer:(Buffer3D *)initbuffer {
	return [self initWithProgram:[Program3D defaultProgram] buffer:initbuffer];
}

- (id)initWithMode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize normalSize:(int)normalsize colorSize:(int)colorsize isDynamic:(BOOL)dynamic {
	for (int i=0, address = 0; i < vcount; i++, address += vertexsize+texcoordssize+normalsize+colorsize) {
		Vector3D v = Vector3DMake(vbuffer[address+0], vbuffer[address+1], vbuffer[address+2]);
		_radius = max(_radius, Vector3DLength(v));
		NSAssert(!isnan(_radius) && isfinite(_radius), nil);
	}
	return [self initWithProgram:[Program3D defaultProgram] buffer:[[Buffer3D alloc] initWithMode:drawmode vertices:vbuffer vertexCount:vcount indices:ibuffer indexCount:icount vertexSize:vertexsize texCoordsSize:texcoordssize normalSize:normalsize colorSize:colorsize isDynamic:dynamic]];
}

- (id)initWithProgram:(Program3D *)initprogram mode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize normalSize:(int)normalsize colorSize:(int)colorsize isDynamic:(BOOL)dynamic {
	return [self initWithProgram:initprogram buffer:[[Buffer3D alloc] initWithMode:drawmode vertices:vbuffer vertexCount:vcount indices:ibuffer indexCount:icount vertexSize:vertexsize texCoordsSize:texcoordssize normalSize:normalsize colorSize:colorsize isDynamic:dynamic]];
}

- (void)setProgram:(Program3D *)initprogram {
	_program = initprogram;
	[_buffer setAttribArraysFromProgram:initprogram];
}
/*
- (id)initWithNormalsCalculatedAsSharp:(BOOL)sharpen vertexBuffer:(Buffer3DVertex *)vertices vertexCount:(int)vcount indices:(GLushort *)indices indexCount:(int)icount isDynamic:(BOOL)dynamic {
	for (int i=0; i < icount; i += 3) {
		Vector3D a = vertices[indices[i+0]].vertex;
		Vector3D b = vertices[indices[i+1]].vertex;
		Vector3D c = vertices[indices[i+2]].vertex;
		Vector3D normal = Vector3DUnit(Vector3DCross(Vector3DSubtract(b, a), Vector3DSubtract(c, b)));
		if (sharpen) {
			vertices[indices[i+0]].normal = normal;
			vertices[indices[i+1]].normal = normal;
			vertices[indices[i+2]].normal = normal;
		} else {
			vertices[indices[i+0]].normal = Vector3DAdd(normal, vertices[indices[i+0]].normal);
			vertices[indices[i+1]].normal = Vector3DAdd(normal, vertices[indices[i+1]].normal);
			vertices[indices[i+2]].normal = Vector3DAdd(normal, vertices[indices[i+2]].normal);
		}
	}
	if (!sharpen)
		for (int i=0; i < vcount; i++)
			vertices[i].normal = Vector3DUnit(vertices[i].normal);
	return [self initWithMode:GL_TRIANGLES vertices:vertices vertexCount:vcount indices:indices indexCount:icount isDynamic:dynamic];
}*/

- (id)copyWithZone:(NSZone *)zone {
	Object3D *copy = [super copyWithZone:zone];
	copy.buffer = _buffer;
	copy.program = _program;
	copy.color = _color;
	copy.colorDark = _colorDark;
	copy.colorLight = _colorLight;
	copy.texture = _texture;
	return copy;
}

- (float)radius {
	return _radius * self.scale;
}

- (void)setColor:(Color2D)color {
	_color = color;
	_colorDark =  Color2DMake(color.r+.03*(color.r < 0.17 ? -1 : +1), color.g, color.b/2., color.alpha);
 	_colorLight = Color2DMake(color.r+.03*(color.r < 0.17 ? +1 : -1), color.g, 1-(1-color.b)/2., color.alpha);  // TODO
}

- (float)opacity {
	return _color.alpha;  // TODO
}

- (void)setOpacity:(float)opacity {
	_color.alpha = opacity;  // TODO
}

- (void)drawWithCamera:(Camera3D *)camera {
	Matrix4x4 modelview = Matrix4x4Multiply(camera.worldToLocal, _localToWorld);

	if (_color.alpha < 1)
		glEnable(GL_BLEND);

	[_program useWithProjection:camera.projection modelView:modelview color:_color texture:_texture];
	[_buffer draw];

	if (_color.alpha < 1)
		glDisable(GL_BLEND);
}

- (void)drawWithCamera:(Camera3D *)camera light:(Light3D *)light {
	Matrix4x4 modelview = Matrix4x4Multiply(camera.worldToLocal, _localToWorld);
	Matrix3x3 normal = Matrix3x3Transpose(Matrix4x4Invert3x3(_localToWorld));

	if (_color.alpha < 1 || _colorDark.alpha < 1 || _colorLight.alpha < 1)
		glEnable(GL_BLEND);

	[_program useWithProjection:camera.projection
					  modelView:modelview
						 normal:normal
					  colorDark:_colorDark
					 colorLight:_colorLight
						texture:_texture
						  light:light.direction
					   position:camera.position];
	[_buffer draw];

	if (_color.alpha < 1 || _colorDark.alpha < 1 || _colorLight.alpha < 1)
		glDisable(GL_BLEND);
}

@end
