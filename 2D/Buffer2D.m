//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Buffer2D.h"


@implementation Buffer2D

- (id)initWithMode:(GLenum)drawmode vertices:(Buffer2DVertex *)vertices vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount isDynamic:(BOOL)dynamic {
	return [super initWithProgram:[Program3D defaultProgram2D] mode:drawmode vertices:(GLfloat *)vertices vertexCount:vcount indices:ibuffer indexCount:icount vertexSize:3 texCoordsSize:2 normalSize:0 colorSize:0 isDynamic:dynamic];
}

- (id)initWithMode:(GLenum)drawmode vertices:(GLfloat *)vertices vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vsize texCoordsSize:(int)texsize colorSize:(int)colorsize isDynamic:(BOOL)dynamic {
	return [super initWithProgram:[Program3D defaultProgram2D] mode:drawmode vertices:(GLfloat *)vertices vertexCount:vcount indices:ibuffer indexCount:icount vertexSize:vsize texCoordsSize:texsize normalSize:0 colorSize:colorsize isDynamic:dynamic];
}

- (void)updateVertices:(Buffer2DVertex *)vertices vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount  {
	[super updateVertices:(GLfloat *)vertices vertexCount:vcount indices:ibuffer indexCount:icount];
}

@end
