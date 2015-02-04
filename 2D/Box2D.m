//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Box2D.h"


@implementation Box2D

- (id)initWithWidth:(float)width height:(float)height {
	static Buffer3D *shared = nil;
	if (!shared) {
		GLfloat vertices[] = {
			0, 1, 0, 0, 1,
			0, 0, 0, 0, 0,
			1, 1, 0, 1, 1,
			1, 0, 0, 1, 0,
		};
		shared = [[Buffer3D alloc] initWithMode:GL_TRIANGLE_STRIP vertices:vertices vertexCount:4 indices:nil indexCount:0 vertexSize:3 texCoordsSize:2 normalSize:0 tangentSize:0 colorSize:0 isDynamic:NO];
	}
	if ((self = [super initWithBuffer:shared])) {
		self.scaleX = width;
		self.scaleY = height;
    }
    return self;
}

@end
