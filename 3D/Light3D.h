//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


@interface Light3D : Object3D
{
	int number;
	float ambient[4], diffuse[4];
}

- (id)initWithDirection:(Vector3D)direction ambient:(GLfloat *)ambient diffuse:(GLfloat *)diffuse;

@end
