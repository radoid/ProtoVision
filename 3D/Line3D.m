//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Line3D.h"


@implementation Line3D

- (id)initWithStart:(Vector3D)point1 end:(Vector3D)point2 {
	static Buffer3D *shared;
	if (!shared) {
		GLfloat vertices[] = {
				0, 0, 0,
				1, 1, 1,
		};
		shared = [[Buffer3D alloc] initWithMode:GL_LINES vertices:vertices vertexCount:2 indices:nil indexCount:0 vertexSize:3 texCoordsSize:0 normalSize:0 tangentSize:0 colorSize:0 isDynamic:NO];
	}
	if ((self = [super initWithBuffer:shared])) {
		Vector3D scale = Vector3DSubtract(point2, point1);
		_scaleX = scale.x;
		_scaleY = scale.y;
		_scaleZ = scale.z;
		self.position = point1;
	}
	return self;
}

@end
