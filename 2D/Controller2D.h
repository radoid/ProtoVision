//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


@interface Controller2D : Controller3D
{
	Camera2D *camera;
	Container2D *stage;
	//float orientation;
}
//@property (nonatomic) float orientation;

- (void)orientationDidChange:(float)angle offsetX:(int)offsetX offsetY:(int)offsetY width:(int)width height:(int)height;

- (void)buttonPressed:(id)button;

@end
