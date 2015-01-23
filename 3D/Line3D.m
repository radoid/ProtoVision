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
	GLfloat vertices[] = {
			point1.x, point1.y, point1.z,
			point2.x, point2.y, point2.z
	};
	return [super initWithMode:GL_LINE_LOOP vertices:vertices vertexCount:2 indices:nil indexCount:0 vertexSize:3 texCoordsSize:0 normalSize:0 colorSize:0 isDynamic:NO];
}

@end
