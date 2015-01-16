//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "Vector3D.h"
#import "Ray3D.h"


typedef struct {
	Vector3D normal;
	float distance;
} Plane3D;


static inline Plane3D Plane3DMake(Vector3D normal, float distance) {
	Plane3D plane = { Vector3DUnit(normal), distance };
	return plane;
}

static inline Plane3D Plane3DMakeWithPoints(Vector3D point1, Vector3D point2, Vector3D point3) {
	Plane3D plane;
	plane.normal = Vector3DUnit(Vector3DCross(Vector3DSubtract(point2, point1), Vector3DSubtract(point3, point1)));
	plane.distance = - (plane.normal.x * point1.x + plane.normal.y * point1.y + plane.normal.z * point1.z);
	return plane;
}

static inline float Plane3DIntersectWithRay(Plane3D plane, Ray3D ray) {
	return - (Vector3DDot (ray.origin, plane.normal) + plane.distance) / Vector3DDot(Vector3DUnit(ray.direction), plane.normal);
}

static inline float Plane3DDistanceToVector(Plane3D plane, Vector3D point) {
	return fabs (plane.normal.x*point.x + plane.normal.y*point.y + plane.normal.z*point.z + plane.distance) / sqrtf (plane.normal.x*plane.normal.x + plane.normal.y*plane.normal.y + plane.normal.z*plane.normal.z);
}

static inline NSString *Plane3DDescription(Plane3D plane) {
	return [NSString stringWithFormat:@"Plane %@, distance %f", Vector3DDescription(plane.normal), plane.distance];
}

/*
 - (float)intersectionWithRayFromPoint:(Vector3D)rayOrigin direction:(Vector3D)rayDirection {
	return - (Vector3DDot (rayOrigin, normal) + distance) / Vector3DDot(Vector3DUnit(rayDirection), normal);
 }

 - (Vector3D)projectionOfPoint:(Vector3D)point {
	float product = (normal.x*point.x + normal.y*point.y + normal.z*point.z + distance) / (normal.x*normal.x + normal.y*normal.y + normal.z*normal.z);
	return Vector3DMake(point.x - normal.x * product, point.y - normal.y * product, point.z - normal.z * product);
 }

 - (float)distanceToPoint:(Vector3D)point {
	return (fabs (normal.x*point.x + normal.y*point.y + normal.z*point.z + distance) / sqrtf (normal.x*normal.x + normal.y*normal.y + normal.z*normal.z));
 }
*/
