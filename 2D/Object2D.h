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
	Program3D *_program;
	Buffer3D *_buffer;
	Texture2D *_texture;
}

@property (nonatomic) Program3D *program;
@property (nonatomic) Buffer3D *buffer;
@property (nonatomic) Color2D color;
@property (nonatomic) float opacity;

- (id)initWithProgram:(Program3D *)initprogram mode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize colorSize:(int)colorsize isDynamic:(BOOL)dynamic;

- (id)initWithMode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize colorSize:(int)colorsize isDynamic:(BOOL)dynamic;

- (id)initWithProgram:(Program3D *)initprogram buffer:(Buffer3D *)initbuffer;

- (id)initWithBuffer:(Buffer3D *)initbuffer;

- (void)setProgram:(Program3D *)initprogram;

- (void)drawWithCamera:(Camera2D *)camera;

@end
