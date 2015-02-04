//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Circle2D.h"

@implementation Circle2D

- (id)initWithRadius:(float)radius steps:(int)steps {
	static Buffer3D *shared = nil;
	if (!shared) {
		int vertexcount = steps+2;
		GLfloat *vertices = calloc(vertexcount, 3*sizeof(GLfloat));
		for (int i=0; i <= steps; i++) {
			vertices[3+i*3+0] = cosf(i*M_PI*2/steps);
			vertices[3+i*3+1] = sinf(i*M_PI*2/steps);
		}
		shared = [[Buffer3D alloc] initWithMode:GL_TRIANGLE_FAN vertices:vertices vertexCount:vertexcount indices:nil indexCount:0 vertexSize:3 texCoordsSize:0 normalSize:0 tangentSize:0 colorSize:0 isDynamic:NO];
	}
	if ((self = [super initWithBuffer:shared])) {
		self.scaleX = self.scaleY = radius;
	}
	return self;
}

@end
