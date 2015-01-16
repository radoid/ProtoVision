//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Light3D.h"


@implementation Light3D

- (id)initWithDirection:(Vector3D)direction ambient:(GLfloat *)initambient diffuse:(GLfloat *)initdiffuse {
	if ((self = [super init])) {
		self.position = direction;
		if (initambient) {
			ambient[0] = initambient[0];
			ambient[1] = initambient[1];
			ambient[2] = initambient[2];
			ambient[3] = initambient[3];
		} else
			ambient[0] = ambient[1] = ambient[2] = ambient[3] = 0;
		if (initdiffuse) {
			diffuse[0] = initdiffuse[0];
			diffuse[1] = initdiffuse[1];
			diffuse[2] = initdiffuse[2];
			diffuse[3] = initdiffuse[3];
		} else
			diffuse[0] = diffuse[1] = diffuse[2] = diffuse[3] = 0;
	}
	return self;
}

@end
