//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

/* TODO

typedef struct {
	float data[4];
} Matrix2D;

inline static Matrix2D Matrix2DMake(float m00, float m01, float m10, float m11) {
	Matrix2D m = {
		m00, m01,
		m10, m11 };
	return m;
}

inline static Matrix2D Matrix2DMultiply(Matrix2D m1, Matrix2D m2) {
	Matrix2D m = {
		m1.data[0]*m2.data[0] + m1.data[1]*m2.data[2], m1.data[0]*m2.data[1] + m1.data[1]*m2.data[3],
		m1.data[2]*m2.data[0] + m1.data[3]*m2.data[2], m1.data[2]*m2.data[1] + m1.data[3]*m2.data[3] };
	return m;
}

inline static Matrix2D Matrix2DTranslate(Matrix2D m1, Matrix2D m2) {
	Matrix2D m = {
		m1.data[0]*m2.data[0] + m1.data[1]*m2.data[2], m1.data[0]*m2.data[1] + m1.data[1]*m2.data[3],
		m1.data[2]*m2.data[0] + m1.data[3]*m2.data[2], m1.data[2]*m2.data[1] + m1.data[3]*m2.data[3] };
	return m;
}

inline static Matrix2D Matrix2DRotate(float angle) {
	angle *= M_PI/180;
	Matrix2D m = {
		cosf(angle), -sinf(angle),
		sinf(angle), cos(angle) };
	return m;
}

inline static Matrix2D Matrix2DInvert() {
	Matrix2D m = {
		m1.data[0]*m2.data[0] + m1.data[1]*m2.data[2], m1.data[0]*m2.data[1] + m1.data[1]*m2.data[3],
		m1.data[2]*m2.data[0] + m1.data[3]*m2.data[2], m1.data[2]*m2.data[1] + m1.data[3]*m2.data[3] };
	return m;
}
*/