#import "Quaternion3DTest.h"

#define EPS 0.00001f


@implementation Quaternion3DTest

- (void)testConstructor {
	Quaternion3D q = Quaternion3DMakeWithAxisAngle(Vector3DY, 45);
	STAssertTrue(q.x == 0 && q.y > 0 && q.z == 0, @"Ne valja kvaternion");
}

- (void)testRotation {
	// Rotacija oko Y za 180'
	Vector3D v = Vector3DMake(1, 1, 1);
	Quaternion3D q = Quaternion3DMakeWithAxisAngle(Vector3DY, 180);
	STAssertTrue(q.x < EPS && q.y > 1-EPS && q.z < EPS && q.w < EPS, @"Ne valja rotacija. Kvaternion je (%f, %f, %f, %f)", q.x, q.y, q.z, q.w);
	v = Vector3DRotateByQuaternion(v, q);
	STAssertEqualsWithAccuracy(-1.f, v.x, EPS, @"Ne valja rotacija za X. Rezultat je vektor (%f, %f, %f)", v.x, v.y, v.z);
	STAssertEqualsWithAccuracy(1.f, v.y, EPS, @"Ne valja rotacija za Y. Rezultat je vektor (%f, %f, %f)", v.x, v.y, v.z);
	STAssertEqualsWithAccuracy(-1.f, v.z, EPS, @"Ne valja rotacija za Z. Rezultat je vektor (%f, %f, %f)", v.x, v.y, v.z);
}

/*    
	id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
	STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
*/

@end
