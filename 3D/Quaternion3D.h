//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "Vector3D.h"


typedef struct {
	GLfloat x, y, z, w;
} Quaternion3D;

static const Quaternion3D Quaternion3DZero = { 0.f, 0.f, 0.f, 1.f };

static inline Quaternion3D Quaternion3DMake(float x, float y, float z, float w) {
	Quaternion3D q = { x, y, z, w };
	return q;
}

static inline void Quaternion3DNormalize(Quaternion3D *quaternion) {
	GLfloat magnitude = sqrtf((quaternion->x * quaternion->x) + (quaternion->y * quaternion->y) + (quaternion->z * quaternion->z) + (quaternion->w * quaternion->w));
	if (magnitude) {
		quaternion->x /= magnitude;
		quaternion->y /= magnitude;
		quaternion->z /= magnitude;
		quaternion->w /= magnitude;
	}
}

static inline Quaternion3D Quaternion3DMakeWithAxisAngle(Vector3D axis, float angle) {
	axis = Vector3DUnit(axis);
	angle = angle / 2 * M_PI / 180;
	float sinAngle = sinf(angle);
	Quaternion3D q = { axis.x * sinAngle, axis.y * sinAngle, axis.z * sinAngle, cosf(angle) };
	//Quaternion3DNormalize(&q);
	return q;
}

static inline Vector3D Quaternion3DAxis(Quaternion3D q) {
	/*Quaternion3DNormalize(&quat);
	GLfloat s = sqrtf(1.0f - (quat.w * quat.w));
	if (fabs(s) < 0.0005f)
		s = 1.0f;
	Vector3D axis = { quat.x / s, quat.y / s, quat.z / s };*/
	//Quaternion3DNormalize(&q);
	float magnitude = sqrtf(q.x * q.x + q.y * q.y + q.z * q.z);
	if (magnitude < 0.0005f)
		magnitude = 1;
	Vector3D axis = { q.x / magnitude, q.y / magnitude, q.z / magnitude };
	if (!(axis.x >= -1 && axis.x <= 1 && axis.y >= -1 && axis.y <= 1 && axis.z >= -1 && axis.z <= 1))
		NSLog(@"Govno!");
	return axis;
}

static inline float Quaternion3DAngle(Quaternion3D q) {
	//Quaternion3DNormalize(&q);
	return (acosf(q.w) * 2 * 180/M_PI);
}

static inline Quaternion3D Quaternion3DMultiply(Quaternion3D quat1, Quaternion3D quat2) {
/*	Vector3D v1 = { quat1.x, quat1.y, quat1.z };
	Vector3D v2 = { quat2.x, quat2.y, quat2.z };
	float angle = (quat1.w * quat2.w) - Vector3DDot(v1, v2);
	Vector3D cp = Vector3DCross(v1, v2);
	Quaternion3D result = {
		v1.x * quat2.w + v2.x * quat1.w + cp.x,
		v1.y * quat2.w + v2.y * quat1.w + cp.y,
		v1.z * quat2.w + v2.z * quat1.w + cp.z,
		angle };*/
	Quaternion3D result = {
		quat1.w * quat2.x + quat1.x * quat2.w + quat1.y * quat2.z - quat1.z * quat2.y,
		quat1.w * quat2.y + quat1.y * quat2.w + quat1.z * quat2.x - quat1.x * quat2.z,
		quat1.w * quat2.z + quat1.z * quat2.w + quat1.x * quat2.y - quat1.y * quat2.x,
		quat1.w * quat2.w - quat1.x * quat2.x - quat1.y * quat2.y - quat1.z * quat2.z };
	/*if (result.w < -1)
		result.w = -1;
	else if (result.w > 1)
		result.w = 1;*/
	return result;
}

static inline Quaternion3D Quaternion3DInvert(Quaternion3D q) {
	GLfloat length = sqrtf((q.x * q.x) + (q.y * q.y) + (q.z * q.z) + (q.w * q.w));
	Quaternion3D q2 = { -q.x / length, -q.y / length, -q.z / length, q.w / length };
	return q2;
}

static inline Quaternion3D Quaternion3DMakeWithEulerAngles(GLfloat x, GLfloat y, GLfloat z) {
	Quaternion3D qx = Quaternion3DMakeWithAxisAngle(Vector3DX, x);
	Quaternion3D qy = Quaternion3DMakeWithAxisAngle(Vector3DY, y);
	Quaternion3D qz = Quaternion3DMakeWithAxisAngle(Vector3DZ, z);
	return Quaternion3DMultiply(Quaternion3DMultiply(qx, qy), qz);
}

static inline Quaternion3D Quaternion3DMakeWithNLERP(Quaternion3D *start, Quaternion3D *finish, GLclampf progress) {
    Quaternion3D ret;
    GLfloat inverseProgress = 1.0f - progress;
    ret.x = (start->x * inverseProgress) + (finish->x * progress);     
    ret.y = (start->y * inverseProgress) + (finish->y * progress);
    ret.z = (start->z * inverseProgress) + (finish->z * progress);
    ret.w = (start->w * inverseProgress) + (finish->w * progress);
    Quaternion3DNormalize(&ret);
    return ret;
}

static inline GLfloat Quaternion3DDot(Quaternion3D *quart1, Quaternion3D *quart2) {
    return quart1->x * quart2->x + quart2->y * quart2->y + quart1->z * quart2->z + quart1->w * quart2->w;
}

static inline Quaternion3D Quaternion3DMakeWithSLERP(Quaternion3D *start, Quaternion3D *finish, GLclampf progress) {
    GLfloat startWeight, finishWeight, difference;
    Quaternion3D ret;
    
    difference = ((start->x * finish->x) + (start->y * finish->y) + (start->z * finish->z) + (start->w * finish->w));
    if ((1.f - fabs(difference)) > .01f) 
    {
        GLfloat theta, oneOverSinTheta;
        
        theta = acosf(fabsf(difference));
        oneOverSinTheta = (1.f / sinf(theta));
        startWeight = (sinf(theta * (1.f - progress)) * oneOverSinTheta);
        finishWeight = (sinf(theta * progress) * oneOverSinTheta);
        if (difference < 0.f) 
            startWeight = -startWeight;
    } else 
    {
        startWeight = (1.f - progress);
        finishWeight = progress;
    }
    ret.x = (start->x * startWeight) + (finish->x * finishWeight);
    ret.y = (start->y * startWeight) + (finish->y * finishWeight);
    ret.z = (start->z * startWeight) + (finish->z * finishWeight);
    ret.w = (start->w * startWeight) + (finish->w * finishWeight);
    Quaternion3DNormalize(&ret);
    
    return ret;
}


static inline Quaternion3D Quaternion3DMakeWithMatrix(GLfloat m00, GLfloat m01, GLfloat m02, GLfloat m10, GLfloat m11, GLfloat m12, GLfloat m20, GLfloat m21, GLfloat m22) {
	Quaternion3D q;
	float t = m00 + m11 + m22;
	
	if (t >= 0) {
		float s = (float) sqrtf(t+1);
		q.w = 0.5f * s;
		s = 0.5f / s;
		q.x = (m21 - m12) * s;
		q.y = (m02 - m20) * s;
		q.z = (m10 - m01) * s;
	} else if ((m00 > m11) && (m00 > m22)) {
		float s = (float) sqrtf(1.0f + m00 - m11 - m22);
		q.x = s * 0.5f;
		s = 0.5f / s;
		q.y = (m10 + m01) * s;
		q.z = (m02 + m20) * s;
		q.w = (m21 - m12) * s;
	} else if (m11 > m22) {
		float s = (float) sqrtf(1.0f + m11 - m00 - m22);
		q.y = s * 0.5f;
		s = 0.5f / s;
		q.x = (m10 + m01) * s;
		q.z = (m21 + m12) * s;
		q.w = (m02 - m20) * s;
	} else {
		float s = (float) sqrtf(1.0f + m22 - m00 - m11);
		q.z = s * 0.5f;
		s = 0.5f / s;
		q.x = (m02 + m20) * s;
		q.y = (m21 + m12) * s;
		q.w = (m10 - m01) * s;
	}
	return q;
}

static inline Quaternion3D Quaternion3DMakeWithVector(Vector3D v) {
	Quaternion3D q = { v.x, v.y, v.z, 0 };
	return q;
}

static inline Vector3D Vector3DMakeWithQuaternion(Quaternion3D q) {
	Vector3D v = { q.x, q.y, q.z };
	return v;
}

static inline Vector3D Vector3DRotateByQuaternion(Vector3D v, Quaternion3D q) {
	return Vector3DMakeWithQuaternion(Quaternion3DMultiply(Quaternion3DMultiply(q, Quaternion3DMakeWithVector(v)), Quaternion3DInvert(q)));
}

static inline Vector3D Vector3DRotateAroundByQuaternion(Vector3D v, Vector3D center, Quaternion3D q) {
	return Vector3DAdd(center, Vector3DRotateByQuaternion(Vector3DSubtract(v, center), q));
}

static inline Vector3D Vector3DRotateByAxisAngle(Vector3D v, Vector3D axis, GLfloat angle) {
	return Vector3DRotateByQuaternion(v, Quaternion3DMakeWithAxisAngle(axis, angle));
}

static inline Vector3D Vector3DRotateAroundByAxisAngle(Vector3D v, Vector3D center, Vector3D axis, GLfloat angle) {
	return Vector3DAdd(center, Vector3DRotateByAxisAngle(Vector3DSubtract(v, center), axis, angle));
}

static inline Quaternion3D Quaternion3DRotateByQuaternion(Quaternion3D q1, Quaternion3D q2) {
	return Quaternion3DMultiply(q2, q1);
}

static inline Quaternion3D Quaternion3DRotateByAxisAngle(Quaternion3D q1, Vector3D axis, GLfloat angle) {
	Quaternion3D q2 = Quaternion3DMakeWithAxisAngle(axis, angle);
	return Quaternion3DMultiply(q2, q1);
}

static inline Quaternion3D Quaternion3DMakeWithTwoVectors(Vector3D from, Vector3D to) {
	Vector3D axis = Vector3DCross(from, to);
	float length1 = Vector3DLength(from);
	float length2 = Vector3DLength(to);
	if (!length1 || !length2)
		return Quaternion3DZero;//NSAssert(length1 > 0 && length2 > 0, @"Nul-vektor u Quaternion3DMakeWithTwoVectors!");
	/*float angle = 0;
	float length = Vector3DLength(axis);
	if (length)
		angle = asinf(length / Vector3DLength(v1) / Vector3DLength(v2)) * 180/M_PI;  // TODO +angle ili -angle?
	else if (!Vector3DEquals(v1, v2)) {
		angle = 180;
		axis = Vector3DCross(v1, Vector3DMake(v1.x+1, v1.y+2, v1.z+3));
	}*/
	float angle = acosf(Vector3DDot(from, to) / length1 / length2) * 180/M_PI;
	return Quaternion3DMakeWithAxisAngle(axis, angle);
	// TODO je li kvaternion ispravan za flip-rotaciju?
}

static inline Quaternion3D Quaternion3DMakeWithThreeVectors(Vector3D axisX, Vector3D axisY, Vector3D axisZ) {
	axisX = Vector3DUnit(axisX);
	axisY = Vector3DUnit(axisY);
	axisZ = Vector3DUnit(axisZ);
	return Quaternion3DMakeWithMatrix(axisX.x, axisY.x, axisZ.x, axisX.y, axisY.y, axisZ.y, axisX.z, axisY.z, axisZ.z);
}

static inline Quaternion3D Quaternion3DMakeWithFourVectors(Vector3D forward1, Vector3D up1, Vector3D forward2, Vector3D up2) {
	Vector3D normal1 = Vector3DCross(forward1, up1);
	Vector3D normal2 = Vector3DCross(forward2, up2);
	Quaternion3D q1 = Quaternion3DMakeWithTwoVectors(normal1, normal2);
	forward1 = Vector3DRotateByQuaternion(forward1, q1);
	Quaternion3D q2 = Quaternion3DMakeWithTwoVectors(forward1, forward2);
	return Quaternion3DMultiply(q2, q1);
}

static inline NSString *Quaternion3DDescription(Quaternion3D q) {
	return [NSString stringWithFormat:@"Quaternion %@, angle %f", Vector3DDescription(Quaternion3DAxis(q)), Quaternion3DAngle(q)];
}
