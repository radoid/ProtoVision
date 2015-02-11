//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"

@class Container3D;


@interface Object3D : NSObject <NSCopying>
{
	GLfloat _x, _y, _z;
	GLfloat _rotationAngle;
	Vector3D _rotationAxis;
	Quaternion3D _rotation;
	GLfloat _scaleX, _scaleY, _scaleZ;
	Container3D __weak *_parent;
	Matrix4x4 _localToWorld, _worldToLocal;
}
@property (nonatomic) GLfloat x, y, z;
@property (nonatomic) Vector3D position;
@property (nonatomic, readonly) Vector3D forward, up, right;
@property (nonatomic) GLfloat scale, scaleX, scaleY, scaleZ;
@property (nonatomic) Vector3D rotationAxis;
@property (nonatomic) GLfloat rotationAngle;
@property (nonatomic) Quaternion3D rotation;
@property (nonatomic, weak) Container3D *parent;
@property (nonatomic) Matrix4x4 localToWorld, worldToLocal;

- (id)initWithPosition:(Vector3D)position direction:(Vector3D)forward up:(Vector3D)up;

- (void)setPosition:(Vector3D)position direction:(Vector3D)forward up:(Vector3D)up;
- (void)setPosition:(Vector3D)position lookAt:(Vector3D)center up:(Vector3D)up;

- (void)rotateByAxis:(Vector3D)axis angle:(float)angle;
- (void)rotateByQuaternion:(Quaternion3D)q;
- (void)rotateAround:(Vector3D)point byQuaternion:(Quaternion3D)q;
- (void)rotateAround:(Vector3D)point byAxis:(Vector3D)axis angle:(float)angle;

- (void)directTo:(Vector3D)forward up:(Vector3D)up;
- (void)lookAt:(Vector3D)center up:(Vector3D)up;

- (void)addTo:(Container3D *)parent;
- (void)removeFromParent;

- (void)recalculate;

@end
