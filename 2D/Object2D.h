//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"

@class Camera2D;


@interface Object2D : Spatial2D <NSCopying>
{
	Program3D *program;
	Buffer2D *buffer;
	Texture2D *texture;
}

@property (nonatomic) Color2D color;
@property (nonatomic) float opacity;

- (id)initWithProgram:(Program3D *)initprogram mode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize colorSize:(int)colorsize isDynamic:(BOOL)dynamic;

- (id)initWithMode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize colorSize:(int)colorsize isDynamic:(BOOL)dynamic;

- (id)initWithProgram:(Program3D *)initprogram buffer:(Buffer2D *)initbuffer;

- (id)initWithBuffer:(Buffer2D *)initbuffer;

- (void)drawWithCamera:(Camera2D *)camera;

@end
