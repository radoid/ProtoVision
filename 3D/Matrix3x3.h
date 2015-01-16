//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

typedef struct {
	float data[9];
} Matrix3x3;

static const Matrix3x3 Matrix3x3Zero = {0, 0, 0, 0, 0, 0, 0, 0, 0};
static const Matrix3x3 Matrix3x3Identity = {1, 0, 0, 0, 1, 0, 0, 0, 1};

static inline Matrix3x3 Matrix3x3Make(float m00, float m01, float m02, float m10, float m11, float m12, float m20, float m21, float m22) {
	Matrix3x3 m = {m00, m01, m02, m10, m11, m12, m20, m21, m22};
	return m;
}

static inline Matrix3x3 Matrix3x3Transpose (Matrix3x3 m) {
	float a01 = m.data[1], a02 = m.data[2];
	float a12 = m.data[5];

	m.data[1] = m.data[3];
	m.data[2] = m.data[6];
	m.data[5] = m.data[7];
	m.data[3] = a01;
	m.data[6] = a02;
	m.data[7] = a12;

	return m;
}
