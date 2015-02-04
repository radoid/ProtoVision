//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "Pyramid3D.h"


@implementation Pyramid3D

- (id)initWithWidth:(float)width height:(float)height {
	static Buffer3D *shared = nil;
	if (!shared) {
		static GLfloat vertices[] = {
			-0.5, 0, -0.5, 0.f, 0.f, 0.f, -1.f, 0.f,  // base
			0.5, 0, -0.5, 0.f, 0.f, 0.f, -1.f, 0.f,
			0.5, 0, 0.5, 0.f, 0.f, 0.f, -1.f, 0.f,
			-0.5, 0, 0.5, 0.f, 0.f, 0.f, -1.f, 0.f,

			0.5, 0, 0.5, 0.f, 0.f, 0, 0.5, 0.57735,    // ispred
			0, 1.f, 0, 0.f, 0.f, 0, 0.5, 0.57735,
			-0.5, 0, 0.5, 0.f, 0.f, 0, 0.5, 0.57735,

			-0.5, 0, -0.5, 0.f, 0.f, 0, 0.5, -0.57735,    // iza
			0, 1.f, 0, 0.f, 0.f, 0, 0.5, -0.57735,
			0.5, 0, -0.5, 0.f, 0.f, 0, 0.5, -0.57735,

			-0.5, 0, 0.5, 0.f, 0.f, -0.57735, 0.5, 0,    // lijevo
			0, 1.f, 0, 0.f, 0.f, -0.57735, 0.5, 0,
			-0.5, 0, -0.5, 0.f, 0.f, -0.57735, 0.5, 0,

			0.5, 0, -0.5, 0.f, 0.f, 0.57735, 0.5, 0,    // desno
			0, 1.f, 0, 0.f, 0.f, 0.57735, 0.5, 0,
			0.5, 0, 0.5, 0.f, 0.f, 0.57735, 0.5, 0,
		};
		static GLushort indices[] = {
			0, 1, 2, 2, 3, 0,
			4, 5, 6,
			7, 8, 9,
			10, 11, 12,
			13, 14, 15,
		};
		shared = [[Buffer3D alloc] initWithMode:GL_TRIANGLES vertices:vertices vertexCount:sizeof(vertices) / sizeof(GLfloat) / 8 indices:indices indexCount:sizeof(indices) / sizeof(GLushort) vertexSize:3 texCoordsSize:2 normalSize:3 tangentSize:0 colorSize:0 isDynamic:NO];
	}
	if ((self = [super initWithBuffer:shared])) {
		self.scaleX = width;
		self.scaleY = height;
		self.scaleZ = width;
	}
	return self;
}

@end
