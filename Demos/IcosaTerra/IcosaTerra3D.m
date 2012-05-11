#import "IcosaTerra3D.h"


@implementation IcosaTerra3D

static inline Vector3D calculateNormal(float i, float j, int k, float di, float dj, int n, Buffer3DVertex *vertices) {
	VectorIJK ijk = VectorIJKMake(i + di, j + dj, k);
	//int m = round ((k*(n+1) + i*n)*(2*n+1) + j*n) * (3+3);
	//int m2 = round ((ijk.k*(n+1) + ijk.i*n)*(2*n+1) + ijk.j*n) * (3+3);
	int m = ((k*(n+1) + round(i*n))*(2*n+1) + round(j*n));
	int m2 = ((ijk.k*(n+1) + round(ijk.i*n))*(2*n+1) + round(ijk.j*n));
	Vector3D v = vertices[m].vertex;
	Vector3D v2 = vertices[m2].vertex;
	return Vector3DFlip(Vector3DUnit(Vector3DCross(Vector3DCross(v2, v), Vector3DSubtract(v, v2))));
}

- (id)initWithRadius:(float)initradius height:(float)initheight levels:(int)initn {
	if ((self = [super init])) {
		n = initn;
		radius = initradius;

		heightmap = malloc(5 * (n+1) * (2*n+1) * sizeof(float));
		
		[Perlin init];
		
		// Sastavljanje vrhova
		Buffer3DVertex vertices[5*(n+1)*(2*n+1)];
		int m = 0, m2;
		for (int k=0; k < 5; k++)
			for (int i=0; i <= n; i++)
				for (int j=0; j <= 2*n; j++) {
					Vector3D r = Vector3DFromVectorIJK(VectorIJKMake((float)i/n, (float)j/n, k));
					float scale = 2;
					//float height = ((float)random()/RAND_MAX*2-1)*initheight;//(float) (Perlin.noise (r.x * scale, r.y * scale, r.z * scale) * 2 - 1) * initheight;
					float height = ([Perlin noiseAt:Vector3DScale(r, scale)]) * initheight;
					//heightmap[(k*(n+1)+i)*(2*n+1)+j] = 2 * (float) Perlin.turbulance (r.x, r.y, r.z, 2) - 1;
					//heightmap[(k*(n+1)+i)*(2*n+1)+j] += (2 * (float) Perlin.turbulance (r.x, r.y, r.z, 20) - 1) / 4;
					//min = min (min, heightmap[k][i][j]);
					//max = max (max, heightmap[k][i][j]);
					heightmap[(k*(n+1)+i)*(2*n+1)+j] = height;
					Vector3D v = Vector3DScale(r, radius + height);
					vertices[m++] = Buffer3DVertexMake(v.x, v.y, v.z, 0, 0, r.x, r.y, r.z);
				}
		NSAssert(m == 5*(n+1)*(2*n+1), nil);
		NSAssert(m == sizeof(vertices)/sizeof(Buffer3DVertex), nil);
		
		// Izračun pravih normala, prema nagibima
		for (int k=0; k < 5; k++)
			for (float i=0; i <= 1.f; i += 1.f/n)
				for (float j=0; j <= 2*1.f; j += 1.f/n) {
					m = ((k*(n+1) + round(i*n))*(2*n+1) + round(j*n));
					vertices[m].normal = Vector3DUnit(Vector3DAdd(
						calculateNormal (i, j, k, +0, +1, n, vertices), Vector3DAdd(
						calculateNormal (i, j, k, +1, +0, n, vertices), Vector3DAdd(
						calculateNormal (i, j, k, +1, -1, n, vertices), Vector3DAdd(
						calculateNormal (i, j, k, +0, -1, n, vertices), Vector3DAdd(
						calculateNormal (i, j, k, -1, +0, n, vertices),
						calculateNormal (i, j, k, -1, +1, n, vertices)))))));
					//vertices[m].normal.x = normal.x;
					//vertices[m + 4] = normal.y;
					//vertices[m + 5] = normal.z;
				}
		
		// Spajanje normala na šavovima
		for (int k=0; k < 5; k++)
			for (float i=1.f/n; i < 1.f; i += 1.f/n) {
				float j = 0;
				VectorIJK ijk = VectorIJKMake(i, j - 1.f/n, k);
				ijk = VectorIJKMake(ijk.i - 1.f/n, ijk.j, ijk.k);
				float i2 = ijk.i, j2 = ijk.j; int k2 = ijk.k;
				m = ((k*(n+1) + round(i*n))*(2*n+1) + round(j*n));
				m2 = ((k2*(n+1) + round(i2*n))*(2*n+1) + round(j2*n));
				vertices[m].normal = vertices[m2].normal = Vector3DScale(Vector3DAdd(vertices[m].normal, vertices[m2].normal), 0.5f);
				
				j = 2*1.f;
				ijk = VectorIJKMake(i, j + 1.f/n, k);
				ijk = VectorIJKMake(ijk.i + 1.f/n, ijk.j, ijk.k);
				i2 = ijk.i; j2 = ijk.j; k2 = ijk.k;
				m = ((k*(n+1) + round(i*n))*(2*n+1) + round(j*n));
				m2 = ((k2*(n+1) + round(i2*n))*(2*n+1) + round(j2*n));
				vertices[m].normal = vertices[m2].normal = Vector3DScale(Vector3DAdd(vertices[m].normal, vertices[m2].normal), 0.5f);
			}
		
		
		GLushort indices[5*n*((2*n+1)*2+2)];
		m = 0;
		for (int k=0; k < 5; k++)
			for (int i=0; i < n; i++) {
				int m0 = m++;
				for (int j=0; j <= 2*n; j++) {
					indices[m++] = ((k*(n+1) + i)*(2*n+1) + j);
					indices[m++] = ((k*(n+1) + i+1)*(2*n+1) + j);
				}
				indices[m] = indices[m-1]; m++;
				indices[m0] = indices[m0+1];
			}
		NSAssert(m == 5*n*((2*n+1)*2+2), nil);
		NSAssert(m == sizeof(indices)/sizeof(GLushort), nil);
		
		
		/*Buffer3DVertex vertices[12];
		for (int i=0; i < 12; i++) {
			float height = radius + initheight;
			vertices[i] = Buffer3DVertexMake(icosahedron_coords[i].x*height, icosahedron_coords[i].y*height, icosahedron_coords[i].z*height, 0, 0, icosahedron_coords[i].x, icosahedron_coords[i].y, icosahedron_coords[i].z);
		}
		
		GLushort indices[20*3];
		for (int i=0; i < 20*3; i++)
			indices[i] = icosahedron_indices[i - i % 3 + 2 - (i % 3)];*/
		
		vbo = [(Buffer3D *)[Buffer3D alloc] initWithMode:GL_TRIANGLE_STRIP vertexBuffer:vertices vertexCount:sizeof(vertices)/sizeof(Buffer3DVertex) indexBuffer:indices indexCount:sizeof(indices)/sizeof(GLushort) isDynamic:NO];
	}
	return self;
}

- (void)dealloc {
	free(heightmap);
	[vbo release];
	[super dealloc];
}

@end
