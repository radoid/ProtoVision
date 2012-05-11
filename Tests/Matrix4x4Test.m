#import "Matrix4x4Test.h"

#define EPS 0.0001f

@implementation Matrix4x4Test

- (void)testSome {
	Matrix4x4 m = Matrix4x4Make(0, 1, 2, 3, 40, 5, 6, 70, 11, 12, 13, 14, 15, 8, 9, 10);
	STAssertTrue(Matrix4x4Determinant(m) != 0, nil);
	Matrix4x4 m2 = Matrix4x4Multiply(m, Matrix4x4Invert(m));
	for (int i=0; i < 16; i++)
		STAssertEqualsWithAccuracy(Matrix4x4Identity.data[i], m2.data[i], EPS, nil);

	m2 = Matrix4x4Rotate(m, +90, 0, 0, 1);
	m2 = Matrix4x4Rotate(m2, +90, 0, 0, 1);
	m2 = Matrix4x4Rotate(m2, +90, 0, 0, 1);
	m2 = Matrix4x4Rotate(m2, +90, 0, 0, 1);
	for (int i=0; i < 16; i++)
		STAssertEqualsWithAccuracy(m.data[i], m2.data[i], EPS, nil);
}

@end
