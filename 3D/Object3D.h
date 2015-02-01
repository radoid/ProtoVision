//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"

@class Camera3D;


@interface Object3D : Spatial3D <NSCopying>
{
	Program3D *_program;
	Buffer3D *_buffer;
	Texture2D *_texture;
	float _radius;
	Color2D _color, _colorDark, _colorLight;
}
@property (nonatomic) Color2D color, colorDark, colorLight;
@property (nonatomic) Buffer3D *buffer;
@property (nonatomic) Program3D *program;
@property (nonatomic) Texture2D *texture;

- (id)initWithProgram:(Program3D *)initprogram buffer:(Buffer3D *)initbuffer;
- (id)initWithBuffer:(Buffer3D *)initbuffer;

- (id)initWithProgram:(Program3D *)initprogram mode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize normalSize:(int)normalsize colorSize:(int)colorsize isDynamic:(BOOL)dynamic;
- (id)initWithMode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize normalSize:(int)normalsize colorSize:(int)colorsize isDynamic:(BOOL)dynamic;

- (float)radius;

- (float)opacity;
- (void)setOpacity:(float)opacity;

- (void)drawWithCamera:(Camera3D *)camera;
- (void)drawWithCamera:(Camera3D *)camera light:(Light3D *)light;

@end
