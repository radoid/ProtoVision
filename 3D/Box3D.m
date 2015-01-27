//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Box3D.h"


@implementation Box3D

- (id)initWithWidth:(float)width height:(float)height depth:(float)depth {
	static Buffer3D *shared = nil;
	if (!shared) {
		static GLfloat vertices[24*8] = {
			-0.5, -0.5, -0.5, 0.f, 0.f, 0.f, -1.f, 0.f,  // dolje
			0.5, -0.5, -0.5, 0.f, 0.f, 0.f, -1.f, 0.f,
			0.5, -0.5, 0.5, 0.f, 0.f, 0.f, -1.f, 0.f,
			-0.5, -0.5, 0.5, 0.f, 0.f, 0.f, -1.f, 0.f,

			-0.5, 0.5, 0.5, 0.f, 0.f, 0.f, 1.f, 0.f,    // gore
			0.5, 0.5, 0.5, 0.f, 0.f, 0.f, 1.f, 0.f,
			0.5, 0.5, -0.5, 0.f, 0.f, 0.f, 1.f, 0.f,
			-0.5, 0.5, -0.5, 0.f, 0.f, 0.f, 1.f, 0.f,

			-0.5, -0.5, 0.5, 0.f, 0.f, 0.f, 0.f, 1.f,    // ispred
			0.5, -0.5, 0.5, 0.f, 0.f, 0.f, 0.f, 1.f,
			0.5, 0.5, 0.5, 0.f, 0.f, 0.f, 0.f, 1.f,
			-0.5, 0.5, 0.5, 0.f, 0.f, 0.f, 0.f, 1.f,

			-0.5, -0.5, -0.5, 0.f, 0.f, 0.f, 0.f, -1.f,    // iza
			0.5, -0.5, -0.5, 0.f, 0.f, 0.f, 0.f, -1.f,
			0.5, 0.5, -0.5, 0.f, 0.f, 0.f, 0.f, -1.f,
			-0.5, 0.5, -0.5, 0.f, 0.f, 0.f, 0.f, -1.f,

			-0.5, -0.5, -0.5, 0.f, 0.f, -1.f, 0.f, 0.f,    // lijevo
			-0.5, -0.5, 0.5, 0.f, 0.f, -1.f, 0.f, 0.f,
			-0.5, 0.5, 0.5, 0.f, 0.f, -1.f, 0.f, 0.f,
			-0.5, 0.5, -0.5, 0.f, 0.f, -1.f, 0.f, 0.f,

			0.5, -0.5, -0.5, 0.f, 0.f, 1.f, 0.f, 0.f,    // desno
			0.5, -0.5, 0.5, 0.f, 0.f, 1.f, 0.f, 0.f,
			0.5, 0.5, 0.5, 0.f, 0.f, 1.f, 0.f, 0.f,
			0.5, 0.5, -0.5, 0.f, 0.f, 1.f, 0.f, 0.f,
		};
		static GLushort indices[] = {
			0, 1, 2, 2, 3, 0,
			4, 5, 6, 6, 7, 4,
			8, 9, 10, 10, 11, 8,
			12, 14, 13, 14, 12, 15,
			16, 17, 18, 18, 19, 16,
			20, 22, 21, 22, 20, 23,
		};
		shared = [[Buffer3D alloc] initWithMode:GL_TRIANGLES vertices:vertices vertexCount:sizeof(vertices)/sizeof(GLfloat)/8 indices:indices indexCount:sizeof(indices)/sizeof(GLushort) vertexSize:3 texCoordsSize:2 normalSize:3 colorSize:0 isDynamic:NO];
	}
	if ((self = [super initWithBuffer:shared])) {
		self.scaleX = width;
		self.scaleY = height;
		self.scaleZ = depth;
	}
	return self;
}

@end
