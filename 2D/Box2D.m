//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "Box2D.h"


@implementation Box2D
{
	int width, height;
}

- (id)initWithWidth:(float)initwidth height:(float)initheight {
	GLfloat vertices[] = {
		0, height, 0, 0, 1,
		0, 0, 0, 0, 0,
		width, height, 0, 1, 1,
		width, 0, 0, 1, 0
 	};
    if ((self = [super initWithMode:GL_TRIANGLE_STRIP vertices:vertices vertexCount:4 indices:nil indexCount:0 vertexSize:3 texCoordsSize:0 colorSize:0 isDynamic:NO])) {
		width = initwidth;
		height = initheight;
    }
    return self;
}

@end
