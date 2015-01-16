//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "Vector3D.h"


typedef struct {
	Vector3D origin;
	Vector3D direction;
} Ray3D;


static inline Ray3D Ray3DMake(Vector3D origin, Vector3D direction) {
	Ray3D ray = { origin, Vector3DUnit(direction) };
	return ray;
}
