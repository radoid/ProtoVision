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
@property (nonatomic) Color2D color, colorDark, colorLight;

@property (nonatomic, weak) Object3D *parent;
@property (nonatomic) Matrix4x4 localToWorld, worldToLocal;

@property (nonatomic) Texture2D *texture;

- (id)initWithBuffer:(Buffer3D *)initbuffer;
- (id)initWithVertices:(Buffer3DVertex *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount;

- (float)opacity;
- (void)setOpacity:(float)opacity;

- (void)drawWithCamera:(Camera3D *)camera;
- (void)drawWithCamera:(Camera3D *)camera light:(Vector3D)direction;

- (void)rotateByAxis:(Vector3D)axis angle:(float)angle;
- (void)rotateByQuaternion:(Quaternion3D)q;
- (void)rotateAround:(Vector3D)point byQuaternion:(Quaternion3D)q;
- (void)directTo:(Vector3D)forward up:(Vector3D)up;
- (void)lookAt:(Vector3D)center up:(Vector3D)up;
- (void)setPosition:(Vector3D)position lookAt:(Vector3D)center up:(Vector3D)up;

- (void)recalculate;

@end
