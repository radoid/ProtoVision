#import "Plane3DTest.h"
#import "Plane3D.h"

#define EPS 0.00001f


@implementation Plane3DTest

- (void)testConstructor {
	Plane3D plane = Plane3DMakeWithPoints(Vector3DMake(3, 1, -9), Vector3DMake(0, 1, -7), Vector3DMake(0, -5, -8));
	STAssertEqualsWithAccuracy(12/21.84033f, plane.normal.x, EPS, nil);
	STAssertEqualsWithAccuracy(-3/21.84033f, plane.normal.y, EPS, nil);
	STAssertEqualsWithAccuracy(18/21.84033f, plane.normal.z, EPS, nil);
	STAssertEqualsWithAccuracy(129/21.84033f, plane.distance, EPS, nil);
	
	plane = Plane3DMakeWithPoints(Vector3DMake(0.0f, 1.0f, 0.0f), Vector3DMake(0.8903399f, 0.45529646f, 0.0f), Vector3DMake(0.27513015f, 0.45529646f, -0.84676355f));
	STAssertTrue(plane.normal.x > 0 && plane.normal.y > 0 && plane.normal.z < 0, nil);
}

- (void)testIntersection {
	Plane3D plane = Plane3DMakeWithPoints(Vector3DMake(0, 0, 0), Vector3DMake(1, 0, 0), Vector3DMake(1, 0, 1));
	STAssertEqualsWithAccuracy(0.f, Plane3DIntersectWithRay(plane, Ray3DMake(Vector3DZero, Vector3DY)), EPS, nil);
	STAssertEqualsWithAccuracy(-1.f, Plane3DIntersectWithRay(plane, Ray3DMake(Vector3DY, Vector3DY)), EPS, nil);
	STAssertEqualsWithAccuracy(INFINITY, Plane3DIntersectWithRay(plane, Ray3DMake(Vector3DY, Vector3DX)), EPS, nil);
	STAssertEqualsWithAccuracy(INFINITY, Plane3DIntersectWithRay(plane, Ray3DMake(Vector3DY, Vector3DZero)), EPS, nil);
}

/* 
 public void testProjection () throws Exception {
 Plane3D plane = new Plane3D (
 new Vector3D (0, 1, 0),
 new Vector3D (1, 1, 0),
 new Vector3D (1, 1, 1));
 Vector3D p = plane.projection (new Vector3D (100, 100, 100));
 assertEquals (100.f, p.x);
 assertEquals (1.f, p.y);
 assertEquals (100.f, p.z);
 
 plane = new Plane3D (
 new Vector3D (0, 1, -1),
 new Vector3D (0, 0, 0),
 new Vector3D (1, 0, 0));
 p = plane.projection (new Vector3D (100, 100, 100));
 assertEquals (100.f, p.x, EPS);
 assertEquals (0.f, p.y, EPS);
 assertEquals (0.f, p.z, EPS);
 
 for (int i=0; i < 10000; i++) {
 Vector3D v1 = Vector3D.random (), v2 = Vector3D.random (), v3 = Vector3D.random ();
 plane = new Plane3D (v1, v2, v3);
 p = plane.projection (v1);
 assertEquals (v1.x, p.x, EPS);
 assertEquals (v1.y, p.y, EPS);
 assertEquals (v1.z, p.z, EPS);
 p = plane.projection (v2);
 assertEquals (v2.x, p.x, EPS);
 assertEquals (v2.y, p.y, EPS);
 assertEquals (v2.z, p.z, EPS);
 p = plane.projection (v3);
 assertEquals (v3.x, p.x, EPS);
 assertEquals (v3.y, p.y, EPS);
 assertEquals (v3.z, p.z, EPS);
 }
 }
 
 public void testDistance () throws Exception {
 Plane3D plane = new Plane3D (
 new Vector3D (0, 1, 0),
 new Vector3D (1, 1, 0),
 new Vector3D (1, 1, 1));
 assertEquals (1.f, plane.distance, EPS);
 
 plane = new Plane3D (
 new Vector3D (0, 1, -1),
 new Vector3D (0, 0, 0),
 new Vector3D (1, 0, 0));
 assertEquals (0.f, plane.distance, EPS);
 }
*/ 
 @end
