//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "Line2D.h"


@implementation Line2D

- (id)initWithStart:(Vector2D)point1 end:(Vector2D)point2 {
	if ((self = [super init])) {
		GLfloat vertices[] = {
				point1.x, point1.y, 0,
				point2.x, point2.y, 0,
		};
		buffer = [[Buffer3D alloc] initWithMode:GL_LINE_LOOP vertices:vertices vertexCount:2 indices:nil indexCount:0 vertexSize:3 texCoordsSize:0 normalSize:0 colorSize:0 isDynamic:NO];
	}
	return self;
}

@end