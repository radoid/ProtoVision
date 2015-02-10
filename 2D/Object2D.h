//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


@interface Object2D : NSObject <NSCopying>
{
	float _x, _y;
	float _rotation;
	float _scaleX, _scaleY;
	CGPoint _origin;
	id __weak _parent;
	Matrix4x4 _localToWorld, _worldToLocal;
}

@property (nonatomic) float x, y, rotation, scale, scaleX, scaleY;
@property (nonatomic) CGPoint origin; // TODO
@property (nonatomic) Vector2D position;
@property (nonatomic, weak) id parent;
@property (nonatomic) Matrix4x4 localToWorld, worldToLocal;

- (void)recalculate;

@end
