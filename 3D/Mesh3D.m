//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Mesh3D.h"
#import "Light3D.h"


@implementation Mesh3D

- (id)init {
	if ((self = [super init])) {
		_color = Color2DMake(1, 1, 1, 1);
		_colorAmbient = Color2DMake(0, 0, 0, 0);
		_colorSpecular = Color2DMake(0, 0, 0, 0);
	}
	return self;
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

- (id)initWithMode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize normalSize:(int)normalsize tangentSize:(int)tansize colorSize:(int)colorsize isDynamic:(BOOL)dynamic {
	int stride = vertexsize+texcoordssize+normalsize+tansize+colorsize;
	for (int i=0, address = 0; i < vcount; i++, address += stride) {
		Vector3D v = Vector3DMake(vbuffer[address+0], vbuffer[address+1], vbuffer[address+2]);
		_radius = max(_radius, Vector3DLength(v));
		NSAssert(!isnan(_radius) && isfinite(_radius), nil);
	}
	//[Mesh3D calculateTangentsWithVertices:vbuffer vertexCount:vcount vertexSize:vertexsize texCoordsSize:texcoordssize normalSize:normalsize tangentSize:tansize colorSize:colorsize];
	return [self initWithProgram:[Program3D defaultProgram] buffer:[[Buffer3D alloc] initWithMode:drawmode vertices:vbuffer vertexCount:vcount indices:ibuffer indexCount:icount vertexSize:vertexsize texCoordsSize:texcoordssize normalSize:normalsize tangentSize:tansize colorSize:colorsize isDynamic:dynamic]];
}

- (id)initWithProgram:(Program3D *)program mode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize normalSize:(int)normalsize tangentSize:(int)tansize colorSize:(int)colorsize isDynamic:(BOOL)dynamic {
	return [self initWithProgram:program buffer:[[Buffer3D alloc] initWithMode:drawmode vertices:vbuffer vertexCount:vcount indices:ibuffer indexCount:icount vertexSize:vertexsize texCoordsSize:texcoordssize normalSize:normalsize tangentSize:tansize colorSize:colorsize isDynamic:dynamic]];
}

- (void)setProgram:(Program3D *)program {
	_program = program;
	[_buffer setAttribArraysFromProgram:program];
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
	Mesh3D *copy = [super copyWithZone:zone];
	copy.buffer = _buffer;
	copy.program = _program;
	copy.colorAmbient = _colorAmbient;
	copy.color = _color;
	copy.colorMap = _colorMap;
	return copy;
}

+ (void)calculateTangentsWithVertices:(GLfloat *)vbuffer vertexCount:(int)vcount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize normalSize:(int)normalsize tangentSize:(int)tansize colorSize:(int)colorsize {
	int stride = vertexsize+texcoordssize+normalsize+tansize+colorsize;
	for (int i=0; i < vcount; i++) {
		vbuffer[i*stride + vertexsize+texcoordssize+normalsize + 0] = -1;
		vbuffer[i*stride + vertexsize+texcoordssize+normalsize + 1] = 0;
		vbuffer[i*stride + vertexsize+texcoordssize+normalsize + 2] = 0;
	}
}

- (float)radius {
	return _radius * self.scale;
}

- (Color2D)colorDiffuse {
	return _color;
}

- (void)setColorDiffuse:(Color2D)color {
	_color = color;
	//_colorAmbient =  Color2DMake(color.r+.03*(color.r < 0.17 ? -1 : +1), color.g, color.b/2., color.alpha);
	//_color = Color2DMake(color.r+.03*(color.r < 0.17 ? +1 : -1), color.g, 1-(1-color.b)/2., color.alpha);  // TODO
}

- (float)opacity {
	return _color.alpha;  // TODO
}

- (void)setOpacity:(float)opacity {
	_color.alpha = opacity;  // TODO
}

- (void)drawWithCamera:(Camera3D *)camera {
	[self drawWithCamera:camera light:nil];
}

- (void)drawWithCamera:(Camera3D *)camera light:(Light3D *)light {
	[self drawWithCamera:camera light:light program:_program];
}

- (void)drawWithCamera:(Camera3D *)camera light:(Light3D *)light program:(Program3D *)program {
	if (_color.alpha < 1)
		glEnable(GL_BLEND);

	if (!program)
		program = _program;
	if (light) {
		Matrix4x4 modelview = Matrix4x4Multiply(camera.worldToLocal, _localToWorld);
		Matrix3x3 normal = Matrix3x3Transpose(Matrix4x4Invert3x3(_localToWorld));
		[program useWithProjection:camera.projection model:_localToWorld view:camera.worldToLocal modelView:modelview normal:normal color:_color colorAmbient:_colorAmbient colorSpecular:_colorSpecular colorSize:_buffer.colorsize colorMap:_colorMap normalMap:_normalMap specularMap:_specularMap ambientOcclusionMap:_ambientOcclusionMap light:light eye:camera.position];
	} else {
		Matrix4x4 modelview = Matrix4x4Multiply(camera.worldToLocal, _localToWorld);
		[program useWithProjection:camera.projection modelView:modelview color:_color texture:_colorMap];
	}

	if (program != _program)
		[_buffer setAttribArraysFromProgram:program];

	[_buffer draw];

	if (program != _program)
		[_buffer setAttribArraysFromProgram:_program];

	if (_color.alpha < 1)
		glDisable(GL_BLEND);
}

@end
