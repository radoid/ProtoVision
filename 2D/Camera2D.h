//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


@interface Camera2D : Spatial2D
{
	CGRect _frame;
	float _near, _far;
	float _orientation;
	Matrix4x4 _projection;
}
@property (nonatomic) CGRect frame;
@property (nonatomic) float orientation;
@property (nonatomic, readonly) Matrix4x4 projection;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame near:(float)near far:(float)far;

@end
