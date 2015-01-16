//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "Polygon2D.h"


@implementation Polygon2D

- (id)initWithRadius:(float)radius corners:(int)corners {
    if ((self = [super init])) {
		Buffer2DVertex vertexBuffer[corners+2];
		vertexBuffer[0] = (Buffer2DVertex) {0, 0, 0, 0, 0};
		for (int i=0; i <= corners; i++) {
			vertexBuffer[1+i] = (Buffer2DVertex) {cosf(i*2*M_PI/corners)*radius, sinf(i*2*M_PI/corners)*radius, 0, 0, 0};
		}
		buffer = [[Buffer2D alloc] initWithMode:GL_TRIANGLE_FAN vertices:vertexBuffer vertexCount:(int) sizeof(vertexBuffer) / sizeof(Buffer2DVertex) indices:nil indexCount:0 isDynamic:NO];
    }
    return self;
}

@end
