//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


@interface Camera3D : Object3D
{
	float near, far, fovy, aspect;
	float orientationAngle;
	Matrix4x4 projection;
}
@property (nonatomic) float aspect, orientation;
@property (nonatomic) Matrix4x4 projection;

- (id)initWithPosition:(Vector3D)position lookAt:(Vector3D)center up:(Vector3D)up fovy:(float)fovy aspect:(float)aspect near:(float)near far:(float)far;

- (Vector2D)project:(Vector3D)position to:(CGRect)frame;
- (Ray3D)unproject:(Vector2D)point from:(CGRect)frame;

@end
