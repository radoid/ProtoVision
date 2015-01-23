//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Line2D.h"


@implementation Line2D

- (id)initWithStart:(Vector2D)point1 end:(Vector2D)point2 {
	GLfloat vertices[] = {
		point1.x, point1.y, 0,
		point2.x, point2.y, 0,
	};
	return [super initWithMode:GL_LINE_LOOP vertices:vertices vertexCount:2 indices:nil indexCount:0 vertexSize:3 texCoordsSize:0 colorSize:0 isDynamic:NO];
}

@end