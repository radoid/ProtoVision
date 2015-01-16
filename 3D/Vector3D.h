//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import <Foundation/Foundation.h>
#import <math.h>
#import "Matrix4x4.h"

#define EPS 0.000001


struct Vector3D {
	float x;
	float y;
	float z;
};
typedef struct Vector3D Vector3D;

static const Vector3D Vector3DZero = { 0.f, 0.f, 0.f };
static const Vector3D Vector3DX = { 1.f, 0.f, 0.f };
static const Vector3D Vector3DY = { 0.f, 1.f, 0.f };
static const Vector3D Vector3DZ = { 0.f, 0.f, 1.f };
static const Vector3D Vector3DZFlip = { 0.f, 0.f, -1.f };

static Vector3D Vector3DMake(float newx, float newy, float newz) {
	Vector3D v;
	v.x = newx;
	v.y = newy;
	v.z = newz;
	return v;
}

static BOOL Vector3DEmpty(Vector3D v) {
	return (!v.x && !v.y && !v.z);
}

static BOOL Vector3DEquals(Vector3D v1, Vector3D v2) {
	return (v1.x == v2.x && v1.y == v2.y && v1.z == v2.z);  // TODO: EPS
}

static float Vector3DLength(Vector3D v) {
	return sqrtf(v.x*v.x + v.y*v.y + v.z*v.z);
}

static Vector3D Vector3DFlip(Vector3D v) {
	v.x = - v.x;
	v.y = - v.y;
	v.z = - v.z;
	return v;
}

static Vector3D Vector3DScale(Vector3D v, float scale) {
	v.x *= scale;
	v.y *= scale;
	v.z *= scale;
	return v;
}

static Vector3D Vector3DUnit(Vector3D v) {
	if (fabs(v.x) > EPS || fabs(v.y) > EPS || fabs(v.z) > EPS) {
		float length = Vector3DLength(v);
		v.x /= length;
		v.y /= length;
		v.z /= length;
	} else
		v = Vector3DMake(1, 0, 0);
	return v;
}

static Vector3D Vector3DAdd (Vector3D v1, Vector3D v2) {
	v1.x += v2.x;
	v1.y += v2.y;
	v1.z += v2.z;
	return v1;
}

static Vector3D Vector3DSubtract (Vector3D v1, Vector3D v2) {
	v1.x -= v2.x;
	v1.y -= v2.y;
	v1.z -= v2.z;
	return v1;
}

static float Vector3DDistance (Vector3D v1, Vector3D v2) {
	return sqrtf((v1.x-v2.x)*(v1.x-v2.x) + (v1.y-v2.y)*(v1.y-v2.y) + (v1.z-v2.z)*(v1.z-v2.z));
}

static float Vector3DDistance2 (Vector3D v1, Vector3D v2) {
	return (v1.x-v2.x)*(v1.x-v2.x) + (v1.y-v2.y)*(v1.y-v2.y) + (v1.z-v2.z)*(v1.z-v2.z);
}

static float Vector3DDot (Vector3D v1, Vector3D v2) {
	return (v1.x * v2.x + v1.y * v2.y + v1.z * v2.z);
}

static Vector3D Vector3DCross (Vector3D v1, Vector3D v2) {
	return (Vector3DMake(v1.y * v2.z - v1.z * v2.y, v1.z * v2.x - v1.x * v2.z, v1.x * v2.y - v1.y * v2.x));
}

static Vector3D Vector3DRandom () {
	return Vector3DMake((float)random() / RAND_MAX * 2 - 1, (float)random() / RAND_MAX * 2 - 1, (float)random() / RAND_MAX * 2 - 1);
}

static inline Vector3D Vector3DMultiply(Vector3D v, Matrix4x4 m) {
	return Vector3DMake(
		m.data[0]*v.x + m.data[4]*v.y + m.data[8]*v.z + m.data[12],
		m.data[1]*v.x + m.data[5]*v.y + m.data[9]*v.z + m.data[13],
		m.data[2]*v.x + m.data[6]*v.y + m.data[10]*v.z + m.data[14]);
}

static inline NSString *Vector3DDescription(Vector3D v) {
	return [NSString stringWithFormat:@"(%ff, %ff, %ff)", v.x, v.y, v.z];
}

#undef EPS
