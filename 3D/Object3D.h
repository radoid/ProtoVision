//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"

@class Camera3D;


@interface Object3D : NSObject <NSCopying>
{
	GLfloat x, y, z;
	GLfloat rotationAngle;
	Vector3D rotationAxis;
	Quaternion3D rotation;
	GLfloat scaleX, scaleY, scaleZ;
	Program3D *program;
	Buffer3D *buffer;
	Texture2D *texture;
	Color2D color, colorDark, colorLight;

	Object3D __weak *parent;
	Matrix4x4 localToWorld, worldToLocal;
}
@property (nonatomic) GLfloat x, y, z;
@property (nonatomic) Vector3D position;
@property (nonatomic, readonly) Vector3D forward, up, right;
@property (nonatomic) GLfloat scale, scaleX, scaleY, scaleZ;
@property (nonatomic) Vector3D rotationAxis;
@property (nonatomic) GLfloat rotationAngle;
@property (nonatomic) Quaternion3D rotation;
@property (nonatomic) Matrix4x4 localToWorld, worldToLocal;

@property (nonatomic, weak) Object3D *parent;
@property (nonatomic) Color2D color, colorDark, colorLight;
@property (nonatomic) Buffer3D *buffer;
@property (nonatomic) Program3D *program;
@property (nonatomic) Texture2D *texture;

- (id)initWithProgram:(Program3D *)initprogram buffer:(Buffer3D *)initbuffer;
- (id)initWithProgram:(Program3D *)initprogram mode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize normalSize:(int)normalsize colorSize:(int)colorsize isDynamic:(BOOL)dynamic;

- (id)initWithBuffer:(Buffer3D *)initbuffer;

- (id)initWithMode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vertexsize texCoordsSize:(int)texcoordssize normalSize:(int)normalsize colorSize:(int)colorsize isDynamic:(BOOL)dynamic;

- (float)opacity;
- (void)setOpacity:(float)opacity;

- (void)rotateByAxis:(Vector3D)axis angle:(float)angle;
- (void)rotateByQuaternion:(Quaternion3D)q;
- (void)rotateAround:(Vector3D)point byQuaternion:(Quaternion3D)q;
- (void)directTo:(Vector3D)forward up:(Vector3D)up;
- (void)lookAt:(Vector3D)center up:(Vector3D)up;
- (void)setPosition:(Vector3D)position lookAt:(Vector3D)center up:(Vector3D)up;

- (void)recalculate;

- (void)drawWithCamera:(Camera3D *)camera;
- (void)drawWithCamera:(Camera3D *)camera light:(Vector3D)direction;

@end
