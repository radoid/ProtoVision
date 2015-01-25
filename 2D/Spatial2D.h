//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


@interface Spatial2D : NSObject <NSCopying>
{
	float x, y;
	float rotation;
	float scaleX, scaleY;
	CGPoint _origin;
	id __weak parent;
	Matrix4x4 localToWorld, worldToLocal;
}

@property (nonatomic) float x, y, rotation, scale, scaleX, scaleY;
@property (nonatomic) CGPoint origin; // TODO
@property (nonatomic) Vector2D position;
@property (nonatomic, weak) id parent;
@property (nonatomic) Matrix4x4 localToWorld, worldToLocal;

- (void)recalculate;

@end