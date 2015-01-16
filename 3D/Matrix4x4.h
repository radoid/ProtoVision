//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import <math.h>
#import "Matrix3x3.h"


typedef struct {
	float data[16];
} Matrix4x4;

static const Matrix4x4 Matrix4x4Zero = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
static const Matrix4x4 Matrix4x4Identity = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};

static inline Matrix4x4 Matrix4x4Make(float m00, float m01, float m02, float m03, float m10, float m11, float m12, float m13, float m20, float m21, float m22, float m23, float m30, float m31, float m32, float m33) {
	Matrix4x4 m = {m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32, m33 };
	return m;
}
/*
static inline Matrix4x4 Matrix4x4FromQuaternion(Quaternion3D q) {
	float x = q.x, y = q.y, z = q.z, w = q.w;
	float x2 = x + x;
	float y2 = y + y;
	float z2 = z + z;
	float xx = x*x2;
	float xy = x*y2;
	float xz = x*z2;
	float yy = y*y2;
	float yz = y*z2;
	float zz = z*z2;
	float wx = w*x2;
	float wy = w*y2;
	float wz = w*z2;

	Matrix4x4 m = {
		1 - (yy + zz), xy - wz, xz + wy, 0,
		xy + wz, 1 - (xx + zz), yz - wx, 0,
		xz - wy, yz + wx, 1 - (xx + yy), 0,
		0, 0, 0, 1 };
	return m;
}*/

static inline Matrix4x4 Matrix4x4Perspective (float fovy, float aspect, float near, float far) {
	float top = (near * tanf (fovy/2 * M_PI/180));
	float bottom = -top;
	float right = top * aspect;
	float left = -right;

	Matrix4x4 m = {
		(near*2) / (right - left), 0, 0, 0,
		0, (near*2) / (top - bottom), 0, 0,
		(right + left) / (right - left), (top + bottom) / (top - bottom), -(far + near) / (far - near), -1,
		0, 0, -(far*near*2) / (far - near), 0};
	return m;
}

static inline Matrix4x4 Matrix4x4Ortho (float left, float right, float bottom, float top, float near, float far) {
	Matrix4x4 m = {
		2 / (right - left), 0, 0, 0,
		0, 2 / (top - bottom), 0, 0,
		0, 0, -2 / (far - near), 0,
		-(left + right) / (right - left), -(top + bottom) / (top - bottom), -(far + near) / (far - near), 1};
	return m;
}

static inline Matrix4x4 Matrix4x4Transpose (Matrix4x4 m) {
	float a01 = m.data[1], a02 = m.data[2], a03 = m.data[3];
	float a12 = m.data[6], a13 = m.data[7];
	float a23 = m.data[11];

	m.data[1] = m.data[4];
	m.data[2] = m.data[8];
	m.data[3] = m.data[12];
	m.data[4] = a01;
	m.data[6] = m.data[9];
	m.data[7] = m.data[13];
	m.data[8] = a02;
	m.data[9] = a12;
	m.data[11] = m.data[14];
	m.data[12] = a03;
	m.data[13] = a13;
	m.data[14] = a23;
	
	return m;
}

static inline float Matrix4x4Determinant (Matrix4x4 m) {
	float a00 = m.data[0], a01 = m.data[1], a02 = m.data[2], a03 = m.data[3];
	float a10 = m.data[4], a11 = m.data[5], a12 = m.data[6], a13 = m.data[7];
	float a20 = m.data[8], a21 = m.data[9], a22 = m.data[10], a23 = m.data[11];
	float a30 = m.data[12], a31 = m.data[13], a32 = m.data[14], a33 = m.data[15];
	
	return
		a30*a21*a12*a03 - a20*a31*a12*a03 - a30*a11*a22*a03 + a10*a31*a22*a03 +
		a20*a11*a32*a03 - a10*a21*a32*a03 - a30*a21*a02*a13 + a20*a31*a02*a13 +
		a30*a01*a22*a13 - a00*a31*a22*a13 - a20*a01*a32*a13 + a00*a21*a32*a13 +
		a30*a11*a02*a23 - a10*a31*a02*a23 - a30*a01*a12*a23 + a00*a31*a12*a23 +
		a10*a01*a32*a23 - a00*a11*a32*a23 - a20*a11*a02*a33 + a10*a21*a02*a33 +
		a20*a01*a12*a33 - a00*a21*a12*a33 - a10*a01*a22*a33 + a00*a11*a22*a33;
}

static inline Matrix4x4 Matrix4x4Invert (Matrix4x4 m) {
	float a00 = m.data[0], a01 = m.data[1], a02 = m.data[2], a03 = m.data[3];
	float a10 = m.data[4], a11 = m.data[5], a12 = m.data[6], a13 = m.data[7];
	float a20 = m.data[8], a21 = m.data[9], a22 = m.data[10], a23 = m.data[11];
	float a30 = m.data[12], a31 = m.data[13], a32 = m.data[14], a33 = m.data[15];

	float b00 = a00*a11 - a01*a10;
	float b01 = a00*a12 - a02*a10;
	float b02 = a00*a13 - a03*a10;
	float b03 = a01*a12 - a02*a11;
	float b04 = a01*a13 - a03*a11;
	float b05 = a02*a13 - a03*a12;
	float b06 = a20*a31 - a21*a30;
	float b07 = a20*a32 - a22*a30;
	float b08 = a20*a33 - a23*a30;
	float b09 = a21*a32 - a22*a31;
	float b10 = a21*a33 - a23*a31;
	float b11 = a22*a33 - a23*a32;

	float invDet = 1 / (b00*b11 - b01*b10 + b02*b09 + b03*b08 - b04*b07 + b05*b06);

	m.data[0] = (a11*b11 - a12*b10 + a13*b09)*invDet;
	m.data[1] = (-a01*b11 + a02*b10 - a03*b09)*invDet;
	m.data[2] = (a31*b05 - a32*b04 + a33*b03)*invDet;
	m.data[3] = (-a21*b05 + a22*b04 - a23*b03)*invDet;
	m.data[4] = (-a10*b11 + a12*b08 - a13*b07)*invDet;
	m.data[5] = (a00*b11 - a02*b08 + a03*b07)*invDet;
	m.data[6] = (-a30*b05 + a32*b02 - a33*b01)*invDet;
	m.data[7] = (a20*b05 - a22*b02 + a23*b01)*invDet;
	m.data[8] = (a10*b10 - a11*b08 + a13*b06)*invDet;
	m.data[9] = (-a00*b10 + a01*b08 - a03*b06)*invDet;
	m.data[10] = (a30*b04 - a31*b02 + a33*b00)*invDet;
	m.data[11] = (-a20*b04 + a21*b02 - a23*b00)*invDet;
	m.data[12] = (-a10*b09 + a11*b07 - a12*b06)*invDet;
	m.data[13] = (a00*b09 - a01*b07 + a02*b06)*invDet;
	m.data[14] = (-a30*b03 + a31*b01 - a32*b00)*invDet;
	m.data[15] = (a20*b03 - a21*b01 + a22*b00)*invDet;
	
	return m;
}

static inline Matrix3x3 Matrix4x4Invert3x3 (Matrix4x4 m) {
	float a00 = m.data[0], a01 = m.data[1], a02 = m.data[2];
	float a10 = m.data[4], a11 = m.data[5], a12 = m.data[6];
	float a20 = m.data[8], a21 = m.data[9], a22 = m.data[10];

	float b01 = a22*a11-a12*a21;
	float b11 = -a22*a10+a12*a20;
	float b21 = a21*a10-a11*a20;

	float d = a00*b01 + a01*b11 + a02*b21;
	if (d == 0)
		return Matrix3x3Zero;
	float invDet = 1/d;

	return Matrix3x3Make (b01*invDet, (-a22*a01 + a02*a21)*invDet, (a12*a01 - a02*a11)*invDet, b11*invDet, (a22*a00 - a02*a20)*invDet, (-a12*a00 + a02*a10)*invDet, b21*invDet, (-a21*a00 + a01*a20)*invDet, (a11*a00 - a01*a10)*invDet);
}

static inline Matrix4x4 Matrix4x4Multiply (Matrix4x4 m, Matrix4x4 m2) {
	float a00 = m.data[0], a01 = m.data[1], a02 = m.data[2], a03 = m.data[3];
	float a10 = m.data[4], a11 = m.data[5], a12 = m.data[6], a13 = m.data[7];
	float a20 = m.data[8], a21 = m.data[9], a22 = m.data[10], a23 = m.data[11];
	float a30 = m.data[12], a31 = m.data[13], a32 = m.data[14], a33 = m.data[15];
	
	float b00 = m2.data[0], b01 = m2.data[1], b02 = m2.data[2], b03 = m2.data[3];
	float b10 = m2.data[4], b11 = m2.data[5], b12 = m2.data[6], b13 = m2.data[7];
	float b20 = m2.data[8], b21 = m2.data[9], b22 = m2.data[10], b23 = m2.data[11];
	float b30 = m2.data[12], b31 = m2.data[13], b32 = m2.data[14], b33 = m2.data[15];
	
	m.data[0] = b00*a00 + b01*a10 + b02*a20 + b03*a30;
	m.data[1] = b00*a01 + b01*a11 + b02*a21 + b03*a31;
	m.data[2] = b00*a02 + b01*a12 + b02*a22 + b03*a32;
	m.data[3] = b00*a03 + b01*a13 + b02*a23 + b03*a33;
	m.data[4] = b10*a00 + b11*a10 + b12*a20 + b13*a30;
	m.data[5] = b10*a01 + b11*a11 + b12*a21 + b13*a31;
	m.data[6] = b10*a02 + b11*a12 + b12*a22 + b13*a32;
	m.data[7] = b10*a03 + b11*a13 + b12*a23 + b13*a33;
	m.data[8] = b20*a00 + b21*a10 + b22*a20 + b23*a30;
	m.data[9] = b20*a01 + b21*a11 + b22*a21 + b23*a31;
	m.data[10] = b20*a02 + b21*a12 + b22*a22 + b23*a32;
	m.data[11] = b20*a03 + b21*a13 + b22*a23 + b23*a33;
	m.data[12] = b30*a00 + b31*a10 + b32*a20 + b33*a30;
	m.data[13] = b30*a01 + b31*a11 + b32*a21 + b33*a31;
	m.data[14] = b30*a02 + b31*a12 + b32*a22 + b33*a32;
	m.data[15] = b30*a03 + b31*a13 + b32*a23 + b33*a33;
	
	return m;
}

static inline Matrix4x4 Matrix4x4Translate (Matrix4x4 m, float x, float y, float z) {
	m.data[12] = m.data[0]*x + m.data[4]*y + m.data[8]*z + m.data[12];
	m.data[13] = m.data[1]*x + m.data[5]*y + m.data[9]*z + m.data[13];
	m.data[14] = m.data[2]*x + m.data[6]*y + m.data[10]*z + m.data[14];
	m.data[15] = m.data[3]*x + m.data[7]*y + m.data[11]*z + m.data[15];
	
	return m;
}

static inline Matrix4x4 Matrix4x4Scale (Matrix4x4 m, float x, float y, float z) {
	m.data[0] *= x;
	m.data[1] *= x;
	m.data[2] *= x;
	m.data[3] *= x;
	m.data[4] *= y;
	m.data[5] *= y;
	m.data[6] *= y;
	m.data[7] *= y;
	m.data[8] *= z;
	m.data[9] *= z;
	m.data[10] *= z;
	m.data[11] *= z;

	return m;
}

static inline Matrix4x4 Matrix4x4Rotate (Matrix4x4 m, float angle, float axisX, float axisY, float axisZ) {
	angle *= M_PI / 180;
	float x = axisX, y = axisY, z = axisZ;
	float len = sqrtf (x*x + y*y + z*z);
	if (len == 0)
		return m;
	if (len != 1) {
		len = 1 / len;
		x *= len;
		y *= len;
		z *= len;
	}

	float s = sinf (angle);
	float c = cosf (angle);
	float t = 1-c;

	float a00 = m.data[0], a01 = m.data[1], a02 = m.data[2], a03 = m.data[3];
	float a10 = m.data[4], a11 = m.data[5], a12 = m.data[6], a13 = m.data[7];
	float a20 = m.data[8], a21 = m.data[9], a22 = m.data[10], a23 = m.data[11];

	float b00 = x*x*t + c, b01 = y*x*t + z*s, b02 = z*x*t - y*s;
	float b10 = x*y*t - z*s, b11 = y*y*t + c, b12 = z*y*t + x*s;
	float b20 = x*z*t + y*s, b21 = y*z*t - x*s, b22 = z*z*t + c;

	m.data[0] = a00*b00 + a10*b01 + a20*b02;
	m.data[1] = a01*b00 + a11*b01 + a21*b02;
	m.data[2] = a02*b00 + a12*b01 + a22*b02;
	m.data[3] = a03*b00 + a13*b01 + a23*b02;

	m.data[4] = a00*b10 + a10*b11 + a20*b12;
	m.data[5] = a01*b10 + a11*b11 + a21*b12;
	m.data[6] = a02*b10 + a12*b11 + a22*b12;
	m.data[7] = a03*b10 + a13*b11 + a23*b12;

	m.data[8] = a00*b20 + a10*b21 + a20*b22;
	m.data[9] = a01*b20 + a11*b21 + a21*b22;
	m.data[10] = a02*b20 + a12*b21 + a22*b22;
	m.data[11] = a03*b20 + a13*b21 + a23*b22;

	return m;
}
