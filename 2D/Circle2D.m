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
	static Buffer2D *shared;
	if (!shared) {
		int vertexcount = steps+2;
		GLfloat *vertices = calloc(vertexcount, 2*sizeof(GLfloat));
		for (int i=0; i <= steps; i++) {
			vertices[2+i*2+0] = cosf(i*M_PI*2/steps);
			vertices[2+i*2+1] = sinf(i*M_PI*2/steps);
		}
		shared = [[Buffer2D alloc] initWithMode:GL_TRIANGLE_FAN vertices:vertices vertexCount:vertexcount indices:nil indexCount:0 vertexSize:2 texCoordsSize:0 colorSize:0 isDynamic:NO];
	}
	if ((self = [super initWithBuffer:shared])) {
		self.scaleX = self.scaleY = radius;
	}
	return self;
}

@end
