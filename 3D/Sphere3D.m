//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "Sphere3D.h"


@implementation Sphere3D

- (id)initWithRadius:(float)radius levels:(int)n {
	Buffer3DVertex vertices[2*n * (n-1) + 2];
	int m = 0;
	vertices[m++] = Buffer3DVertexMake(0, radius, 0, 0, 0, 0, 1, 0);
	for (int j=0; j < 2*n; j++) {
		for (int i=1; i < n; i++) {
			float vy = radius * cosf(i * M_PI / n);
			float r = radius * sinf(i * M_PI / n);
			float vx = r * sinf(j * 2*M_PI / (2*n));
			float vz = r * cosf(j * 2*M_PI / (2*n));
			vertices[m++] = Buffer3DVertexMake(vx, vy, vz, 0, 0, vx / radius, vy / radius, vz / radius);
		}
	}
	vertices[m++] = Buffer3DVertexMake(0, -radius, 0, 0, 0, 0, -1, 0);
	NSAssert(m == sizeof(vertices)/sizeof(Buffer3DVertex), nil, nil);

	GLushort indices[(2*n-0) * ((n-1)*2 + 2+2)];
	m = 0;
	for (int j=0; j < (2*n-0); j++) {
		indices[m++] = 0;
		indices[m++] = 0;
		for (int i=1; i < n; i++) {
			indices[m++] = (short) (((j+1)%(2*n))*(n-1) + i);
			indices[m++] = (short) (j*(n-1) + i);
		}
		indices[m++] = (short) (sizeof(vertices)/sizeof(Buffer3DVertex) - 1);
		indices[m++] = (short) (sizeof(vertices)/sizeof(Buffer3DVertex) - 1);
	}
	NSAssert(m == sizeof(indices)/sizeof(GLushort), nil);

	return [super initWithBuffer:[[Buffer3D alloc] initWithMode:GL_TRIANGLE_STRIP vertices:vertices vertexCount:sizeof(vertices)/sizeof(GLfloat)/8 indices:indices indexCount:sizeof(indices)/sizeof(GLushort) vertexSize:3 texCoordsSize:2 normalSize:3 colorSize:0 isDynamic:NO]];
}

@end
