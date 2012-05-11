#import "VectorIJKTest.h"


@implementation VectorIJKTest

static int n = 80;
#define EPS  0.0005f

- (void)setUp {
}

- (void)calculateCoords {
	float R = 2 * sqrtf (5) / 5;
	float h = sqrtf (5) / 5;
	float S = sqrtf (50 - 10 * sqrtf (5)) / 5;
	
	Vector3D coords[12];
	h = (float) sqrtf (5) / 5;  // visine dviju "glavnih pruga"
	R = 2 * h;  // polumjer dviju "glavnih pruga"
	S = (float) sqrtf (50 - 10 * sqrtf (5)) / 5;  // duljina stranice
	
	coords[0] = Vector3DMake(0, 1, 0);
	for (int i=0; i < 5; i++) {
		coords[1+i] = Vector3DMake((float) (R * cosf(-i*2*M_PI/5)), h, (float) (R * sinf(-i*2*M_PI/5)));
		coords[6+i] = Vector3DMake((float) (R * cosf(-(i-0.5)*2*M_PI/5)), -h, (float) (R * sinf(-(i-0.5)*2*M_PI/5)));
	}
	coords[11] = Vector3DMake(0, -1, 0);
	//for (int i=0; i < 12; i++)
	//	NSLog(@"\t%ff, %ff, %ff,", coords[i].x, coords[i].y, coords[i].z);
	
	int indices[20*3];
	for (int k=0, m=0; k < 5; k++) {
		indices[m++] = 0;
		indices[m++] = 1+(k+1)%5;
		indices[m++] = 1+k;
		indices[m++] = 6+(k+1)%5;
		indices[m++] = 1+k;
		indices[m++] = 1+(k+1)%5;
		indices[m++] = 1+k;
		indices[m++] = 6+(k+1)%5;
		indices[m++] = 6+k;
		indices[m++] = 11;
		indices[m++] = 6+k;
		indices[m++] = 6+(k+1)%5;
	}
	//for (int i=0; i < 20; i++)
	//	NSLog(@"\t%d, %d, %d,", indices[i*3], indices[i*3+1], indices[i*3+2]);
	
	Vector3D centers[20];
	for (int t=0; t < 20; t++)
		centers[t] = Vector3DScale(Vector3DAdd(Vector3DAdd(coords[indices[t*3]], coords[indices[t*3+1]]), coords[indices[t*3+2]]), 1/3.f);
	for (int i=0; i < 20; i++)
		NSLog(@"\t{ %ff, %ff, %ff },", centers[i].x, centers[i].y, centers[i].z);
}

- (void)testConstructor {
	VectorIJK ijk = VectorIJKMake(3.f/n, 1.f/n, 4);
	STAssertEqualsWithAccuracy(3.f/n, ijk.i, EPS, nil);
	STAssertEqualsWithAccuracy(1.f/n, ijk.j, EPS, nil);
	STAssertEqualsWithAccuracy(4, ijk.k, EPS, nil);
	
	// test ravno nagore
	ijk = VectorIJKMake(-1.f/n, 1.f + 1.f/n, 0);
	STAssertEqualsWithAccuracy(1.f - 1.f/n, ijk.i, EPS, nil);
	STAssertEqualsWithAccuracy(1.f/n, ijk.j, EPS, nil);
	STAssertEqualsWithAccuracy(4, ijk.k, EPS, nil);
	
	// test ravno nadolje
	ijk = VectorIJKMake(1.f + 1.f/n, 3.f/n, 4);
	STAssertEqualsWithAccuracy(1.f/n, ijk.i, EPS, nil);
	STAssertEqualsWithAccuracy(1.f + 3.f/n, ijk.j, EPS, nil);
	STAssertEqualsWithAccuracy(0, ijk.k, EPS, nil);
	
	// test nadesno nagore
	ijk = VectorIJKMake(1.f, 2.f + 1.f/n, 0);
	STAssertEqualsWithAccuracy(1.f - 1.f/n, ijk.i, EPS, nil);
	STAssertEqualsWithAccuracy(2.f, ijk.j, EPS, nil);
	STAssertEqualsWithAccuracy(4, ijk.k, EPS, nil);
	for (int k=0; k < 5; k++)
		for (float i=0; i <= 1.f; i += 1.f/n) {
			ijk = VectorIJKMake(i, 2.f + 1.f/n, k);
			STAssertEqualsWithAccuracy(1.f - 1.f/n, ijk.i, EPS, nil);
			STAssertEqualsWithAccuracy(1.f + i, ijk.j, EPS, nil);
			STAssertEqualsWithAccuracy((k-1+5)%5, ijk.k, EPS, nil);
		}
	
	// test nadolje nalijevo
	ijk = VectorIJKMake(1.f + 1.f/n, 1.f + 3.f/n, 1);
	STAssertEqualsWithAccuracy(3.f/n, ijk.i, EPS, nil);
	STAssertEqualsWithAccuracy(2.f - 1.f/n, ijk.j, EPS, nil);
	STAssertEqualsWithAccuracy(2, ijk.k, EPS, nil);
	for (int k=0; k < 5; k++)
		for (float i=0; i <= 1.f; i += 1.f/n) {
			ijk = VectorIJKMake(i, 0 - 1.f/n, k);
			STAssertEqualsWithAccuracy(1.f/n, ijk.i, EPS, nil);
			STAssertEqualsWithAccuracy(i, ijk.j, EPS, nil);
			STAssertEqualsWithAccuracy((k+1)%5, ijk.k, EPS, nil);
		}
}

- (void)testToVector3D {
	VectorIJK ijk = VectorIJKMake(0, 0, 0);
	Vector3D v = Vector3DFromVectorIJK(ijk);
	STAssertEqualsWithAccuracy(0.f, v.x, EPS, nil);
	STAssertEqualsWithAccuracy(1.f, v.y, EPS, nil);
	STAssertEqualsWithAccuracy(0.f, v.z, EPS, nil);
	
	ijk = VectorIJKMake(1.f, 2*1.f, 4);
	v = Vector3DFromVectorIJK(ijk);
	STAssertEqualsWithAccuracy(0.f, v.x, EPS, nil);
	STAssertEqualsWithAccuracy(-1.f, v.y, EPS, nil);
	STAssertEqualsWithAccuracy(0.f, v.z, EPS, nil);
	
	ijk = VectorIJKMake(0, 1.f, 0);
	v = Vector3DFromVectorIJK(ijk);
	STAssertEqualsWithAccuracy(icosahedron_R, v.x, EPS, nil);
	STAssertEqualsWithAccuracy(icosahedron_h, v.y, EPS, nil);
	STAssertEqualsWithAccuracy(0.f, v.z, EPS, nil);
	
	ijk = VectorIJKMake(0.5f, 0.5f, 3);
	v = Vector3DFromVectorIJK(ijk);
	Vector3D expected = Vector3DUnit(Vector3DScale(Vector3DAdd(icosahedron_coords[4], icosahedron_coords[5]), 0.5f));
	//NSLog(@"icosahedron_coords[4] = %ff, %ff, %ff,", icosahedron_coords[4].x, icosahedron_coords[4].y, icosahedron_coords[4].z);
	//NSLog(@"icosahedron_coords[5] = %ff, %ff, %ff,", icosahedron_coords[5].x, icosahedron_coords[5].y, icosahedron_coords[5].z);
	//NSLog(@"expected = %ff, %ff, %ff,", expected.x, expected.y, expected.z);
	//NSLog(@"v = %ff, %ff, %ff,", v.x, v.y, v.z);
	STAssertEqualsWithAccuracy(expected.x, v.x, EPS, nil);
	STAssertEqualsWithAccuracy(expected.y, v.y, EPS, nil);
	STAssertEqualsWithAccuracy(expected.z, v.z, EPS, nil);
	
}

- (void)testFromVector3D {
	Vector3D v = Vector3DMake(0, 1, 0);
	VectorIJK ijk = VectorIJKFromVector3D(v);
	STAssertEqualsWithAccuracy(0.f, ijk.i, EPS, nil);
	STAssertEqualsWithAccuracy(0.f, ijk.j, EPS, nil);
	STAssertTrue (ijk.k >= 0 && ijk.k < 5, nil);
	
	v = Vector3DScale(Vector3DAdd(icosahedron_coords[6], icosahedron_coords[7]), 0.5f);
	ijk = VectorIJKFromVector3D(v);
	STAssertEqualsWithAccuracy(0.5f, ijk.i, EPS, nil);
	STAssertEqualsWithAccuracy(1.5f, ijk.j, EPS, nil);
	STAssertEqualsWithAccuracy(0, ijk.k, EPS, nil);
	
	v = Vector3DScale(Vector3DAdd(icosahedron_coords[3], icosahedron_coords[4]), 0.5f);
	ijk = VectorIJKFromVector3D(v);
	STAssertEqualsWithAccuracy(0.5f, ijk.i, EPS, nil);
	STAssertEqualsWithAccuracy(0.5f, ijk.j, EPS, nil);
	STAssertEqualsWithAccuracy(2, ijk.k, EPS, nil);
}

- (void)testAll {
	VectorIJK ijk;

	[self testI2I:VectorIJKMake(0.5f, 0.5f, 3)];
	
	[self testI2I:VectorIJKMake(0.018156005f/8, 10.028105f/8, 0)];
	[self testI2I:VectorIJKMake(7.999998f/8, 8.565621f/8, 0)];
	[self testI2I:VectorIJKMake(7.9999976f/8, 8.388884f/8, 3)];
	[self testI2I:VectorIJKMake(4.404743f/8, 1.1852715E-6f/8, 3)];
	[self testI2I:VectorIJKMake(7.9999986f/8, 9.776506f/8, 3)];
	[self testI2I:VectorIJKMake(1.7746805f/8, 13.8643875f/8, 4)];

	for (int k=0; k < 5; k++)
		for (float i = 1.f/n; i < 1.f; i += 1.f/n)
			for (float j = 1.f/n; j < 2*1.f; j += 1.f/n)
				[self testI2I:VectorIJKMake(i, j, k)];

	for (int c=0; c < 10; c++) {
		ijk = VectorIJKMake((float) random (), 2 * (float) random (), (int) (5 * random ()));
		if (ijk.i > EPS && ijk.i < 1.f-EPS && ((ijk.j > EPS && ijk.j < 1.f-EPS) || (ijk.j > 1.f+EPS && ijk.j < 2*1.f-EPS)))
			[self testI2I:ijk];
	}

	[self testV2V:Vector3DMake(-0.12818906f, 0.48392263f, 0.8656711f)];
	[self testV2V:Vector3DMake(-0.20734122f, -0.945302f, -0.2518208f)];
	
	for (int c=0; c < 10; c++)
		[self testV2V:Vector3DUnit(Vector3DRandom())];
}

- (void)testI2I:(VectorIJK)ijk {
	Vector3D v = Vector3DFromVectorIJK(ijk);
	VectorIJK ijk2 = VectorIJKFromVector3D(v);
	Vector3D v2 = Vector3DFromVectorIJK(ijk2);
	NSString *msg = [NSString stringWithFormat:@"I2I: [%f, %f, %d] -> (%f, %f, %f) -> [%f, %f, %d] -> (%f, %f, %f)", ijk.i, ijk.j, ijk.k, v.x, v.y, v.z, ijk2.i, ijk2.j, ijk2.k, v2.x, v2.y, v2.z];
	STAssertEqualsWithAccuracy(ijk.i, ijk2.i, EPS, msg);
	STAssertEqualsWithAccuracy(ijk.j, ijk2.j, EPS, msg);
	STAssertEqualsWithAccuracy(ijk.k, ijk2.k, EPS, msg);
}

- (void)testV2V:(Vector3D)v {
	VectorIJK ijk = VectorIJKFromVector3D(v);
	Vector3D v2 = Vector3DFromVectorIJK(ijk);
	VectorIJK ijk2 = VectorIJKFromVector3D(v2);
	NSString *msg = [NSString stringWithFormat:@"V2V: (%f, %f, %f) -> [%f, %f, %d] -> (%f, %f, %f) -> [%f, %f, %d]", v.x, v.y, v.z, ijk.i, ijk.j, ijk.k, v2.x, v2.y, v2.z, ijk2.i, ijk2.j, ijk2.k];
	STAssertEqualsWithAccuracy(v.x, v2.x, EPS, msg);
	STAssertEqualsWithAccuracy(v.y, v2.y, EPS, msg);
	STAssertEqualsWithAccuracy(v.z, v2.z, EPS, msg);
}

@end
