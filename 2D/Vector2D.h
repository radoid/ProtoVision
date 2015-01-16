//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import <math.h>

#define EPS 0.000001


typedef struct {
	float x;
	float y;
} Vector2D;

static const Vector2D Vector2DZero = {0, 0};
static const Vector2D Vector2DX = {1, 0};
static const Vector2D Vector2DY = {0, 1};

static inline Vector2D Vector2DMake(float newx, float newy) {
	return (Vector2D) {newx, newy};
}

static inline BOOL Vector2DEqual(Vector2D a, Vector2D b) {
	a.x -= b.x;
	a.y -= b.y;
	return (a.x > -EPS && a.x < EPS && a.y > -EPS && a.y < EPS);
}

static inline Vector2D Vector2DFromCircle(Vector2D v, float radius, float angle) {
	v.x += radius * cosf(angle);
	v.y += radius * sinf(angle);
	return v;
}

static inline float Vector2DLength(Vector2D v) {
	return sqrtf(v.x*v.x + v.y*v.y);
}

static inline Vector2D Vector2DScale(Vector2D v, float scale) {
	v.x *= scale;
	v.y *= scale;
	return v;
}

static inline Vector2D Vector2DUnit(Vector2D v) {
	if (fabs(v.x) > EPS || fabs(v.y) > EPS) {
		float length = Vector2DLength(v);
		v.x /= length;
		v.y /= length;
	}// else
	//	v = Vector2DMake(1, 0);  TODO
	return v;
}

static inline Vector2D Vector2DClamp(Vector2D v, float maxlength) {
	if (fabs(v.x) > EPS || fabs(v.y) > EPS) {
		float length = Vector2DLength(v);
		if (length > maxlength) {
			v.x *= maxlength/length;
			v.y *= maxlength/length;
		}
	}
	return v;
}

static inline Vector2D Vector2DAdd(Vector2D v1, Vector2D v2) {
	v1.x += v2.x;
	v1.y += v2.y;
	return v1;
}

static inline Vector2D Vector2DSubtract(Vector2D v1, Vector2D v2) {
	v1.x -= v2.x;
	v1.y -= v2.y;
	return v1;
}

static inline float Vector2DDistance(Vector2D v1, Vector2D v2) {
	return sqrtf((v1.x-v2.x)*(v1.x-v2.x) + (v1.y-v2.y)*(v1.y-v2.y));
}

static inline float Vector2DDistance2(Vector2D v1, Vector2D v2) {
	return (v1.x-v2.x)*(v1.x-v2.x) + (v1.y-v2.y)*(v1.y-v2.y);
}

static inline float Vector2DDot(Vector2D v1, Vector2D v2) {
	return (v1.x * v2.x + v1.y * v2.y);
}

static inline BOOL Vector2DIntersection(Vector2D s1, Vector2D s2, Vector2D t1, Vector2D t2, Vector2D *intersection) {
	float d = (s1.x-s2.x)*(t1.y-t2.y) - (s1.y-s2.y)*(t1.x-t2.x);
	if (d == 0)
		return NO;
	intersection->x = ((t1.x-t2.x)*(s1.x*s2.y-s1.y*s2.x)-(s1.x-s2.x)*(t1.x*t2.y-t1.y*t2.x)) / d;
	intersection->y = ((t1.y-t2.y)*(s1.x*s2.y-s1.y*s2.x)-(s1.y-s2.y)*(t1.x*t2.y-t1.y*t2.x)) / d;
	if (intersection->x < MIN(s1.x, s2.x)-EPS || intersection->x > MAX(s1.x, s2.x)+EPS || intersection->x < MIN(t1.x, t2.x)-EPS || intersection->x > MAX(t1.x, t2.x)+EPS
	||  intersection->y < MIN(s1.y, s2.y)-EPS || intersection->y > MAX(s1.y, s2.y)+EPS || intersection->y < MIN(t1.y, t2.y)-EPS || intersection->y > MAX(t1.y, t2.y)+EPS)
		return NO;
	return YES;
}

static inline Vector2D Vector2DRandom() {
	return (Vector2D) {
			arc4random()/(float)0x100000000 * 2 - 1,
			arc4random()/(float)0x100000000	* 2 - 1 };
}

static inline Vector2D Vector2DMultiply(Vector2D v, Matrix4x4 m) {
	return (Vector2D) {
		m.data[0]*v.x + m.data[4]*v.y + m.data[12],
		m.data[1]*v.x + m.data[5]*v.y + m.data[13] };
}


static inline Vector2D Vector2DMakePolar(float radius, float angle) {
	return (Vector2D) {cosf(angle)*radius, sinf(angle)*radius};
}

// Angle from -PI to PI
static inline float Vector2DAngle(Vector2D v) {
	return atan2f(v.y, v.x);
}

// Angle from 0 to 2*PI
static inline float Angle2PI(float angle) {
	if (angle >= 2*M_PI)
		return fmod(angle, 2*M_PI);
	if (angle <= -2*M_PI)
		return 2*M_PI + fmod(angle, 2*M_PI);
	if (angle < 0)
		return 2*M_PI + angle;
	return angle;
}

// Angle from -PI to +PI
static inline float AnglePI (float angle) {
	if (angle > 0)
		return fmod(angle + M_PI, 2*M_PI) - M_PI;
	return fmod(angle - M_PI, 2*M_PI) + M_PI;
}

// Smaller of the two angles, from 0 to PI
static inline float AngleDistance(float angle1, float angle2) {
	float distance = fabs(angle1 - angle2);
	if (distance >= 2*M_PI)
		distance = fmod(distance, 2*M_PI);
	return (distance <= M_PI ? distance : 2*M_PI - distance);
}

#undef EPS
