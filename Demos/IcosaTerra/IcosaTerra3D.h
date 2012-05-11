#import <RadEngine/RadEngine.h>


@interface IcosaTerra3D : Object3D
{
	int n;
	float radius;
	float *heightmap;
}
- (id)initWithRadius:(float)initradius height:(float)initheight levels:(int)initn;

@end
