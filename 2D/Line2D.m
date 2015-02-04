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
	static Buffer3D *shared = nil;
	if (!shared) {
		GLfloat vertices[] = {
			0, 0, 0,
			1, 1, 0,
		};
		shared = [[Buffer3D alloc] initWithMode:GL_LINES vertices:vertices vertexCount:2 indices:nil indexCount:0 vertexSize:3 texCoordsSize:0 normalSize:0 tangentSize:0 colorSize:0 isDynamic:NO];
	}
	if ((self = [super initWithBuffer:shared])) {
		Vector2D scale = Vector2DSubtract(point2, point1);
		_scaleX = scale.x;
		_scaleY = scale.y;
		self.position = point1;
	}
	return self;
}

@end