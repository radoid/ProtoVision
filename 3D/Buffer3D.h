//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


typedef struct {
	Vector3D vertex;
	GLfloat texcoords[2];
	Vector3D normal;
} Buffer3DVertex;

static inline Buffer3DVertex Buffer3DVertexMake(GLfloat x, GLfloat y, GLfloat z, GLfloat s, GLfloat t, GLfloat nx, GLfloat ny, GLfloat nz) {
	Buffer3DVertex vertex = { {x, y, z}, {s, t}, {nx, ny, nz} };
	return vertex;
}


@interface Buffer3D : NSObject
{
	Program3D *program;
	GLuint vao;
	GLenum mode;
	GLuint vboname, iboname;
	int vertexcount, maxvertexcount, indexcount, maxindexcount;
	int vertexsize, texcoordssize, normalsize, colorsize;
	int stride;
}

- (id)initWithProgram:(Program3D *)program mode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vsize texCoordsSize:(int)tsize normalSize:(int)nsize colorSize:(int)csize isDynamic:(BOOL)dynamic;

- (id)initWithMode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vsize texCoordsSize:(int)tsize normalSize:(int)nsize colorSize:(int)csize isDynamic:(BOOL)dynamic;
- (id)initWithMode:(GLenum)drawmode vertices:(Buffer3DVertex *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount isDynamic:(BOOL)dynamic;
- (id)initWithNormalsCalculatedAsSharp:(BOOL)sharpen vertexBuffer:(Buffer3DVertex *)vertices vertexCount:(int)vertexcount indices:(GLushort *)indices indexCount:(int)indexcount isDynamic:(BOOL)dynamic;

- (void)updateVertices:(Buffer3DVertex *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount;

//- (void)drawWithProjection:(Matrix4x4)projection modelView:(Matrix4x4)modelview normal:(Matrix3x3)normal color:(Color2D)color light:(Vector3D)direction;
- (void)drawWithProjection:(Matrix4x4)projection modelView:(Matrix4x4)modelview normal:(Matrix3x3)normal colorDark:(Color2D)colorDark colorLight:(Color2D)colorLight texture:(Texture2D *)texture light:(Vector3D)direction position:(Vector3D)position;

- (void)drawWithProjection:(Matrix4x4)projection modelView:(Matrix4x4)modelview color:(Color2D)color texture:(Texture2D *)texture;

@end
