//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"

@class Camera3D;
@class Light3D;


@interface Mesh3D : Object3D <NSCopying>
{
	float _radius;
}
@property (nonatomic) Buffer3D *buffer;
@property (nonatomic) Program3D *program;
@property (nonatomic) Texture2D *colorMap, *normalMap, *specularMap, *ambientOcclusionMap;
@property (nonatomic) Color2D color, colorAmbient, colorSpecular;

- (id)initWithProgram:(Program3D *)program buffer:(Buffer3D *)buffer;
- (id)initWithBuffer:(Buffer3D *)buffer;

- (id)initWithProgram:(Program3D *)program mode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize normalSize:(int)normalsize tangentSize:(int)tansize colorSize:(int)colorsize isDynamic:(BOOL)dynamic;

- (id)initWithMode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize normalSize:(int)normalsize tangentSize:(int)tansize colorSize:(int)colorsize isDynamic:(BOOL)dynamic;

- (float)radius;

- (Color2D)colorDiffuse;

- (void)setColorDiffuse:(Color2D)color;

- (float)opacity;
- (void)setOpacity:(float)opacity;

- (void)drawWithCamera:(Camera3D *)camera;
- (void)drawWithCamera:(Camera3D *)camera light:(Light3D *)light;
- (void)drawWithCamera:(Camera3D *)camera light:(Light3D *)light program:(Program3D *)program;

@end
