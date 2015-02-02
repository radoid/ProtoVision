//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "Sphere3D.h"

typedef struct {
	Vector3D position, normal;
} Vertex;


@implementation Sphere3D

- (id)initWithRadius:(float)radius levels:(int)n {
	Vertex vertices[2*n * (n-1) + 2];
	int m = 0;
	vertices[m++] = (Vertex) {0, radius, 0, 0, 1, 0};
	for (int j=0; j < 2*n; j++) {
		for (int i=1; i < n; i++) {
			float vy = radius * cosf(i * M_PI / n);
			float r = radius * sinf(i * M_PI / n);
			float vx = r * sinf(j * 2*M_PI / (2*n));
			float vz = r * cosf(j * 2*M_PI / (2*n));
			vertices[m++] = (Vertex) {vx, vy, vz, vx / radius, vy / radius, vz / radius};
		}
	}
	vertices[m++] = (Vertex) {0, -radius, 0, 0, -1, 0};

	GLushort indices[(2*n-0) * ((n-1)*2 + 2+2)];
	m = 0;
	for (int j=0; j < (2*n-0); j++) {
		indices[m++] = 0;
		indices[m++] = 0;
		for (int i=1; i < n; i++) {
			indices[m++] = (short) (((j+1)%(2*n))*(n-1) + i);
			indices[m++] = (short) (j*(n-1) + i);
		}
		indices[m++] = (short) (sizeof(vertices)/sizeof(Vertex) - 1);
		indices[m++] = (short) (sizeof(vertices)/sizeof(Vertex) - 1);
	}

	return [super initWithMode:GL_TRIANGLE_STRIP vertices:(GLfloat*)vertices vertexCount:sizeof(vertices)/sizeof(Vertex) indices:indices indexCount:sizeof(indices)/sizeof(GLushort) vertexSize:3 texCoordsSize:0 normalSize:3 colorSize:0 isDynamic:NO];
}

@end
