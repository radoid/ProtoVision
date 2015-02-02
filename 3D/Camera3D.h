//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


@interface Camera3D : Spatial3D <NSCopying>

@property (nonatomic) float fovy, near, far, orientation;
@property (nonatomic) Matrix4x4 projection;

- (id)initWithPerspectiveFOVY:(float)fovy aspect:(float)aspect near:(float)near far:(float)far;
- (id)initWithPerspectivePosition:(Vector3D)position lookAt:(Vector3D)center up:(Vector3D)up fovy:(float)fovy aspect:(float)aspect near:(float)near far:(float)far;
- (id)initWithOrtographicFrame:(CGRect)frame near:(float)near far:(float)far;
- (id)initWithOrtographicPosition:(Vector3D)position lookAt:(Vector3D)center up:(Vector3D)up frame:(CGRect)frame near:(float)near far:(float)far;

- (void)setAspect:(float)aspect;
- (void)setFrame:(CGRect)frame;

- (Vector2D)project:(Vector3D)position to:(CGRect)frame;
- (Ray3D)unproject:(Vector2D)point from:(CGRect)frame;

@end
