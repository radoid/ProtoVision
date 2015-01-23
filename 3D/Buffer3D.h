//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


typedef struct {  // TODO deprecated
	Vector3D vertex;
	GLfloat texcoords[2];
	Vector3D normal;
} Buffer3DVertex;

static inline Buffer3DVertex Buffer3DVertexMake(GLfloat x, GLfloat y, GLfloat z, GLfloat s, GLfloat t, GLfloat nx, GLfloat ny, GLfloat nz) {
	Buffer3DVertex vertex = { {x, y, z}, {s, t}, {nx, ny, nz} };
	return vertex;
}


@interface Buffer3D : NSObject <NSCopying>
{
	GLuint vao;
	GLuint vboname, iboname;
	GLenum mode;
	int vertexcount, maxvertexcount, indexcount, maxindexcount;
	int stride;
}
/*@property (nonatomic, readonly) GLuint vboname, iboname;
@property (nonatomic, readonly) GLenum mode;
@property (nonatomic, readonly) int vertexcount, indexcount;
@property (nonatomic, readonly) int stride;*/

- (id)initWithMode:(GLenum)drawmode vertices:(GLfloat *)vertices vertexCount:(int)vcount stride:(int)stride indices:(GLushort *)indices indexCount:(int)icount isDynamic:(BOOL)dynamic;

- (void)updateVertices:(Buffer3DVertex *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount;

- (void)attrib:(int)index size:(int)size type:(int)type stride:(int)stride1 offset:(int)offset;

- (void)draw;

@end
