//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"

@class Camera2D;


@interface Object2D : NSObject <NSCopying>
{
	float x, y;
	float rotation;
	float scaleX, scaleY;
	Color2D _color;
	CGPoint _origin;
	Program3D *program;
	Buffer2D *buffer;
	Texture2D *texture;

	id __weak parent;
	Matrix4x4 localToWorld, worldToLocal;
}

@property (nonatomic) float x, y, rotation, scale, scaleX, scaleY;
@property (nonatomic) CGPoint origin;
@property (nonatomic) Vector2D position;
@property (nonatomic) Matrix4x4 localToWorld, worldToLocal;

@property (nonatomic) Color2D color;
@property (nonatomic) float opacity;

@property (nonatomic, weak) id parent;
@property (nonatomic, readonly) Buffer2D *buffer;

- (id)initWithProgram:(Program3D *)initprogram mode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize colorSize:(int)colorsize isDynamic:(BOOL)dynamic;

- (id)initWithMode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize colorSize:(int)colorsize isDynamic:(BOOL)dynamic;

- (id)initWithProgram:(Program3D *)initprogram buffer:(Buffer2D *)initbuffer;

- (id)initWithBuffer:(Buffer2D *)initbuffer;
- (void)recalculate;
- (void)drawWithCamera:(Camera2D *)camera;

@end
