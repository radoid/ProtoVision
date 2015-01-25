//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Object3D.h"
#import "Color2D.h"


@implementation Object3D

@synthesize program, buffer, color, colorDark, colorLight, texture;

- (id)init {
	if ((self = [super init])) {
		[self setColor:Color2DMake(0, 0.5, 0.5, 1)];
	}
	return self;
}

- (id)initWithProgram:(Program3D *)initprogram buffer:(Buffer3D *)initbuffer {
	if ((self = [self init])) {
		buffer = initbuffer;
		[self setProgram:initprogram];
	}
	return self;
}

- (id)initWithBuffer:(Buffer3D *)initbuffer {
	return [self initWithProgram:[Program3D defaultProgram] buffer:initbuffer];
}

- (id)initWithProgram:(Program3D *)initprogram mode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize normalSize:(int)normalsize colorSize:(int)colorsize isDynamic:(BOOL)dynamic {
	Buffer3D *buffer = [[Buffer3D alloc] initWithMode:drawmode vertices:vbuffer vertexCount:vcount indices:ibuffer indexCount:icount vertexSize:vertexsize texCoordsSize:texcoordssize normalSize:normalsize colorSize:colorsize isDynamic:dynamic];
	return [self initWithProgram:initprogram buffer:buffer];
}

- (id)initWithMode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize normalSize:(int)normalsize colorSize:(int)colorsize isDynamic:(BOOL)dynamic {
	return [self initWithProgram:[Program3D defaultProgram] mode:drawmode vertices:vbuffer vertexCount:vcount indices:ibuffer indexCount:icount vertexSize:vertexsize texCoordsSize:texcoordssize normalSize:normalsize colorSize:colorsize isDynamic:dynamic];
}

- (void)setProgram:(Program3D *)initprogram {
	program	= initprogram;
	[buffer setAttribForProgram:initprogram];
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
	Object3D *copy = [(Object3D *)[super copyWithZone:zone] initWithProgram:program buffer:buffer];
	copy.color = self.color;
	copy.colorDark = self.colorDark;
	copy.colorLight = self.colorLight;
	copy.texture = self.texture;
	return copy;
}

- (void)setColor:(Color2D)newcolor {
	color = newcolor;
	colorDark =  Color2DMake(newcolor.r+.03*(newcolor.r < 0.17 ? -1 : +1), newcolor.g, newcolor.b/2., newcolor.alpha);
 	colorLight = Color2DMake(newcolor.r+.03*(newcolor.r < 0.17 ? +1 : -1), newcolor.g, 1-(1-newcolor.b)/2., newcolor.alpha);  // TODO
}

- (float)opacity {
	return color.alpha;  // TODO
}

- (void)setOpacity:(float)opacity {
	color.alpha = opacity;  // TODO
}

- (void)drawWithCamera:(Camera3D *)camera {
	Matrix4x4 modelview = Matrix4x4Multiply(camera.worldToLocal, localToWorld);

	if (color.alpha < 1)
		glEnable(GL_BLEND);

	[program useWithProjection:camera.projection modelView:modelview color:color texture:texture];
	[buffer draw];

	if (color.alpha < 1)
		glDisable(GL_BLEND);
}

- (void)drawWithCamera:(Camera3D *)camera light:(Vector3D)direction {
	Matrix4x4 modelview = Matrix4x4Multiply(camera.worldToLocal, localToWorld);
	Matrix3x3 normal = Matrix3x3Transpose(Matrix4x4Invert3x3(localToWorld));

	if (color.alpha < 1 || colorDark.alpha < 1 || colorLight.alpha < 1)
		glEnable(GL_BLEND);

	[program useWithProjection:camera.projection
							modelView:modelview
							   normal:normal
							colorDark:colorDark
						   colorLight:colorLight
							  texture:texture
								light:direction
							 position:camera.position];
	[buffer draw];

	if (color.alpha < 1 || colorDark.alpha < 1 || colorLight.alpha < 1)
		glDisable(GL_BLEND);
}

@end
