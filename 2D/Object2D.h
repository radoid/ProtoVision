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
	Buffer2D *buffer;
	Texture2D *texture;

	id __weak parent;
	Matrix4x4 localToWorld, worldToLocal;
}

@property (nonatomic) float x, y, rotation, scale, scaleX, scaleY;
@property (nonatomic) CGPoint origin;
@property (nonatomic) Vector2D position;
@property (nonatomic) Color2D color;
@property (nonatomic) float opacity;

@property (nonatomic, weak) id parent;
@property (nonatomic) Matrix4x4 localToWorld, worldToLocal;

- (id)initWithBuffer:(Buffer2D *)initbuffer;
- (void)recalculate;
- (void)drawWithCamera:(Camera2D *)camera;

@end
