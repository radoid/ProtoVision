//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "Vector3D.h"
#import "Plane3D.h"
#import "Quaternion3D.h"


static const float icosahedron_h = 0.447214f, icosahedron_R = 0.894427f, icosahedron_S = 1.051462f;

static const Vector3D icosahedron_coords[12] = {
	{ 0.000000f, 1.000000f, 0.000000f },
	{ 0.894427f, 0.447214f, 0.000000f },
	{ 0.276393f, 0.447214f, -0.850651f },
	{ -0.723607f, 0.447214f, -0.525731f },
	{ -0.723607f, 0.447214f, 0.525731f },
	{ 0.276393f, 0.447214f, 0.850651f },
	{ 0.723607f, -0.447214f, 0.525731f },
	{ 0.723607f, -0.447214f, -0.525731f },
	{ -0.276393f, -0.447214f, -0.850651f },
	{ -0.894427f, -0.447214f, 0.000000f },
	{ -0.276393f, -0.447214f, 0.850651f },
	{ 0.000000f, -1.000000f, 0.000000f }};

static const int icosahedron_indices[20*3] = {
	0, 2, 1,
	7, 1, 2,
	1, 7, 6,
	11, 6, 7,
	0, 3, 2,
	8, 2, 3,
	2, 8, 7,
	11, 7, 8,
	0, 4, 3,
	9, 3, 4,
	3, 9, 8,
	11, 8, 9,
	0, 5, 4,
	10, 4, 5,
	4, 10, 9,
	11, 9, 10,
	0, 1, 5,
	6, 5, 1,
	5, 6, 10,
	11, 10, 6 };

static const Vector3D icosahedron_centers[20] = {
	{ 0.390273f, 0.631476f, -0.283550f },
	{ 0.631476f, 0.149071f, -0.458794f },
	{ 0.780547f, -0.149071f, 0.000000f },
	{ 0.482405f, -0.631476f, 0.000000f },
	{ -0.149071f, 0.631476f, -0.458794f },
	{ -0.241202f, 0.149071f, -0.742344f },
	{ 0.241202f, -0.149071f, -0.742344f },
	{ 0.149071f, -0.631476f, -0.458794f },
	{ -0.482405f, 0.631476f, 0.000000f },
	{ -0.780547f, 0.149071f, 0.000000f },
	{ -0.631476f, -0.149071f, -0.458794f },
	{ -0.390274f, -0.631476f, -0.283550f },
	{ -0.149071f, 0.631476f, 0.458794f },
	{ -0.241202f, 0.149071f, 0.742344f },
	{ -0.631476f, -0.149071f, 0.458794f },
	{ -0.390274f, -0.631476f, 0.283550f },
	{ 0.390274f, 0.631476f, 0.283550f },
	{ 0.631476f, 0.149071f, 0.458794f },
	{ 0.241202f, -0.149071f, 0.742344f },
	{ 0.149071f, -0.631476f, 0.458794f }};


typedef struct {
	float i, j;
	int k;
} VectorIJK;


static inline VectorIJK VectorIJKMake(float i, float j, int k) {
	VectorIJK ijk = { i, j, k };
	
	if (i < 0 && j >= 1.f && j <= 2*1.f) {  // jednostavan prelazak na gornji kat
		ijk.k--; ijk.j -= 1.f; ijk.i += 1.f; }
	else if (i > 1.f && j <= 1.f && j >= 0) {  // jednostavan prelazak na donji kat
		ijk.k++; ijk.j += 1.f; ijk.i -= 1.f; }
	else if (j < 0) {  // prelazak s rotacijom nalijevo nadolje
		ijk.k++; ijk.j = i; ijk.i = -j; }
	else if (j > 2*1.f) {  // prelazak s rotacijom nadesno nagore
		ijk.k--; ijk.j = 1.f+i; ijk.i = 1.f-(j-2*1.f); }
	else if (i < 0) {  // prelazak s rotacijom nagore nadesno
		ijk.k--; ijk.j = -i; ijk.i = j; }
	else if (i > 1.f) {  // prelazak s rotacijom nadolje nalijevo
		ijk.k++; ijk.j = 2*1.f - (i-1.f); ijk.i = j-1.f; }
	if (ijk.k == -1)  // katovi se sastavljaju na krajevima
		ijk.k = 4;
	if (ijk.k == 5)  // katovi se sastavljaju na krajevima
		ijk.k = 0;
	//NSString *msg = [NSString stringWithFormat:@"[%f, %f, %f] -> %@", i, j, k, self];
	//assert (ijk.j >= 0 && ijk.j <= 2*1.f && ijk.i >= 0 && ijk.i <= 1.f && ijk.k >= 0 && ijk.k < 5);
	
	return ijk;
}


static inline VectorIJK VectorIJKFromVector3D(Vector3D v) {
	//NSLog(@"v = %@", Vector3DDescription(v));
	v = Vector3DUnit(v);
	float mindistance2 = -1;
	int mint = -1;
	for (int t=0; t < 20; t++) {
		float distance2 = Vector3DDistance2(icosahedron_centers[t], v);
		//NSLog(@"distance2 = %f za t=%d", distance2, t);
		if (t == 0 || distance2 < mindistance2) {
			mint = t;
			mindistance2 = distance2;
		}
	}
	//NSLog(@"center = %@, mint = %d, mindistance2 = %f", Vector3DDescription(icosahedron_centers[mint]), mint, mindistance2);
	
	Vector3D p0 = icosahedron_coords[icosahedron_indices[mint*3]];
	//Vector3D pi = icosahedron_coords[icosahedron_indices[mint*3+1]];
	Vector3D pj = icosahedron_coords[icosahedron_indices[mint*3+2]];
	Plane3D plane = Plane3DMake(icosahedron_centers[mint], - Vector3DLength(icosahedron_centers[mint]));
	//NSLog(@"plane = %@", Plane3DDescription(plane));
	//plane = Plane3DMakeWithPoints(p0, pj, pi);
	//NSLog(@"plane = %@", Plane3DDescription(plane));
	v = Vector3DScale(v, Plane3DIntersectWithRay(plane, Ray3DMake(Vector3DZero, v)));
	v = Vector3DSubtract(v, p0);
	Quaternion3D rotation = Quaternion3DMakeWithTwoVectors(plane.normal, Vector3DY);
	//NSLog(@"rotation = %@", Quaternion3DDescription(rotation));
	v = Vector3DRotateByQuaternion(v, rotation);
	//NSLog(@"v = %@", Vector3DDescription(v));
	Vector3D pj2 = Vector3DRotateByQuaternion(Vector3DSubtract(pj, p0), rotation);
	rotation = Quaternion3DMakeWithTwoVectors(pj2, Vector3DX);
	//NSLog(@"rotation = %@", Quaternion3DDescription(rotation));
	v = Vector3DRotateByQuaternion(v, rotation);
	//NSLog(@"v = %@", Vector3DDescription(v));
	v.z /= -icosahedron_S * sqrtf(3)/2;
	v.x = v.x/icosahedron_S - v.z/2;
	//NSLog(@"v = %@", Vector3DDescription(v));

	return VectorIJKMake(
		(mint % 2 == 0 ? v.z : 1.f - v.z),
		(mint % 2 == 0 ? v.x : 1.f - v.x) + (mint % 4 >= 2 ? 1.f : 0),
		mint/4);
}/*
public VectorIJK (Vector3D v) {
	calculateCoords ();
	
	v = new Vector3D (v).unit ();
	float mindistance2 = -1;
	int mint = -1;
	for (int t=0; t < 20; t++) {
		float distance2 = centers[t].distance2 (v);
		if (t == 0 || distance2 < mindistance2) {
			mint = t;
			mindistance2 = distance2;
		}
	}
	
	Vector3D p0 = coords[indices[mint*3]];
	Vector3D pi = coords[indices[mint*3+1]];
	Vector3D pj = coords[indices[mint*3+2]];
	Plane3D plane = new Plane3D (centers[mint], -centers[mint].length ());
	//Plane3D plane = new Plane3D (p0, pj, pi);
	v.scale (plane.intersection (Vector3D.Zero, v));
	v.subtract (p0);
	Quaternion3D rotation = new Quaternion3D (plane.normal, Vector3D.Y);
	v.rotate (rotation);
	Vector3D pj2 = new Vector3D (pj).subtract (p0).rotate (rotation);
	rotation = new Quaternion3D (pj2, Vector3D.X);
	v.rotate (rotation);
	v.z /= -S * Math.sqrt(3)/2;
	v.x = v.x/S - v.z/2;
	this.i = (mint % 2 == 0 ? v.z * 1.f : 1.f - v.z * 1.f);
	this.j = (mint % 2 == 0 ? v.x * 1.f : 1.f - v.x * 1.f) + (mint % 4 >= 2 ? 1.f : 0);
	this.k = mint/4;
}
*/

static inline Vector3D Vector3DFromVectorIJK(VectorIJK ijk) {
	int t = ijk.k * 4 + (ijk.j > 1.f ? 2 : 0) + ((ijk.j <= 1.f && ijk.j > (1.f-ijk.i)) || (ijk.j > 1.f && ijk.j-1.f > (1.f-ijk.i)) ? 1 : 0);
	Vector3D p0 = icosahedron_coords[icosahedron_indices[t*3]];
	Vector3D pi = Vector3DScale(Vector3DSubtract(icosahedron_coords[icosahedron_indices[t*3+1]], p0), t % 2 == 0 ? ijk.i/1.f : (1.f-ijk.i)/1.f);
	Vector3D pj = Vector3DScale(Vector3DSubtract(icosahedron_coords[icosahedron_indices[t*3+2]], p0), t % 2 == 0 ? (ijk.j <= 1.f ? ijk.j/1.f : (ijk.j-1.f)/1.f) : (ijk.j <= 1.f ? (1.f-ijk.j)/1.f : (1.f-(ijk.j-1.f))/1.f));
	return Vector3DUnit(Vector3DAdd(Vector3DAdd(p0, pi), pj));
}


/*
@interface VectorIJK : NSObject
{
	float i, j;
	int k;
}
@property (nonatomic) float i, j;
@property (nonatomic) int k;

- (id)initWithI:(float)initi j:(float)initj k:(int)initk;
- (id)initWithVector:(Vector3D)v;
- (Vector3D)toVector3D;

+ (void)calculateCoords;

- (NSString *)description;
	
@end



@implementation VectorIJK

@synthesize i, j, k;

- (id)initWithI:(float)initi j:(float)initj k:(int)initk {
	if ((self = [super init])) {
		[VectorIJK calculateCoords];
		i = initi;
		j = initj;
		k = initk;
		
		if (initi < 0 && initj >= 1.f && initj <= 2*1.f) {  // jednostavan prelazak na gornji kat
			k--; j -= 1.f; i += 1.f; }
		else if (initi > 1.f && initj <= 1.f && initj >= 0) {  // jednostavan prelazak na donji kat
			k++; j += 1.f; i -= 1.f; }
		else if (initj < 0) {  // prelazak s rotacijom nalijevo nadolje
			k++; j = initi; i = -initj; }
		else if (initj > 2*1.f) {  // prelazak s rotacijom nadesno nagore
			k--; j = 1.f+initi; i = 1.f-(initj-2*1.f); }
		else if (initi < 0) {  // prelazak s rotacijom nagore nadesno
			k--; j = -initi; i = initj; }
		else if (initi > 1.f) {  // prelazak s rotacijom nadolje nalijevo
			k++; j = 2*1.f - (initi-1.f); i = initj-1.f; }
		if (k == -1)  // katovi se sastavljaju na krajevima
			k = 4;
		if (k == 5)  // katovi se sastavljaju na krajevima
			k = 0;
		//NSString *msg = [NSString stringWithFormat:@"[%f, %f, %f] -> %@", initi, initj, initk, self];
		assert (j >= 0 && j <= 2*1.f && i >= 0 && i <= 1.f && k >= 0 && k < 5);
	}
	return self;
}

- (id)initWithVector:(Vector3D)v {
	if ((self = [super init])) {
		[VectorIJK calculateCoords];
		
		v = Vector3DUnit(v);
		float mindistance2 = -1;
		int mint = -1;
		for (int t=0; t < 20; t++) {
			float distance2 = Vector3DDistance2(centers[t], v);
			if (t == 0 || distance2 < mindistance2) {
				mint = t;
				mindistance2 = distance2;
			}
		}
		
		Vector3D p0 = coords[indices[mint*3]];
		//Vector3D pi = coords[indices[mint*3+1]];
		Vector3D pj = coords[indices[mint*3+2]];
		Plane3D *plane = [[Plane3D alloc] initWithNormal:centers[mint] distance:-Vector3DLength(centers[mint])];
		//Plane3D plane = new Plane3D (p0, pj, pi);
		v = Vector3DScale(v, [plane intersectionWithRayFromPoint:Vector3DZero direction:v]);
		v = Vector3DSubtract(v, p0);
		Quaternion3D rotation = Quaternion3DMakeWithTwoVectors(plane.normal, Vector3DY);
		v = Vector3DRotateByQuaternion(v, rotation);
		Vector3D pj2 = Vector3DRotateByQuaternion(Vector3DSubtract(pj, p0), rotation);
		rotation = Quaternion3DMakeWithTwoVectors(pj2, Vector3DX);
		v = Vector3DRotateByQuaternion(v, rotation);
		v.z /= -S * sqrtf(3)/2;
		v.x = v.x/S - v.z/2;
		i = (mint % 2 == 0 ? v.z * 1.f : 1.f - v.z * 1.f);
		j = (mint % 2 == 0 ? v.x * 1.f : 1.f - v.x * 1.f) + (mint % 4 >= 2 ? 1.f : 0);
		k = mint/4;
	}
	return self;
}

- (Vector3D)toVector3D {
	int t = k * 4 + (j > 1.f ? 2 : 0) + (j <= 1.f && j > (1.f-i) || j > 1.f && j-1.f > (1.f-i) ? 1 : 0);
	Vector3D p0 = coords[indices[t*3]];
	Vector3D pi = Vector3DScale(Vector3DSubtract(coords[indices[t*3+1]], p0), t % 2 == 0 ? i/1.f : (1.f-i)/1.f);
	Vector3D pj = Vector3DScale(Vector3DSubtract(coords[indices[t*3+2]], p0), t % 2 == 0 ? (j <= 1.f ? j/1.f : (j-1.f)/1.f) : (j <= 1.f ? (1.f-j)/1.f : (1.f-(j-1.f))/1.f));
	return Vector3DUnit(Vector3DAdd(Vector3DAdd(p0, pi), pj));
}

+ (void)calculateCoords {
	if (!indices[0] || Vector3DEmpty(coords[0]) || Vector3DEmpty(centers[0])) {
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
		for (int i=0; i < 20; i++)
			NSLog(@"\t%d, %d, %d,", indices[i*3], indices[i*3+1], indices[i*3+2]);
		
		for (int t=0; t < 20; t++)
			centers[t] = Vector3DScale(Vector3DAdd(Vector3DAdd(coords[indices[t*3]], coords[indices[t*3+1]]), coords[indices[t*3+2]]), 1/3.f);
		for (int i=0; i < 12; i++)
			NSLog(@"\t%ff, %ff, %ff,", centers[i].x, centers[i].y, centers[i].z);
	}
}

- (NSString *)description {
	return [NSString stringWithFormat:@"[%f, %f, %f]", i, j, k];
}

@end
*/