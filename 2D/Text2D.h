//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


@interface Text2D : Object2D
{
	NSString *text;
	Font2D *font;
	float scale;
	int alignment;
}
@property (nonatomic, retain) NSString *text;
@property (nonatomic) int alignment;

- (id)initWithFont:(Font2D *)newfont text:(NSString *)newtext size:(float)newsize color:(Color2D)newcolor;
- (void)draw;

@end
