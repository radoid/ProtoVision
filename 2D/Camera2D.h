//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


@interface Camera2D : Object2D
{
	CGRect coords;
	float near, far;
	float orientation;
	Matrix4x4 projection;
}
@property (nonatomic) CGRect frame;
@property (nonatomic) float orientation;
@property (nonatomic, readonly) Matrix4x4 projection;

- (id)initWithFrame:(CGRect)coords;
- (id)initWithFrame:(CGRect)coords near:(float)near far:(float)far;

@end
