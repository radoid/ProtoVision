//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "Text2D.h"


@implementation Text2D

@synthesize text, alignment;

- (id)initWithFont:(Font2D *)newfont text:(NSString *)newtext size:(float)newsize color:(Color2D)newcolor{
	self = [super init];
	font = newfont;
	scale = newsize / newfont.commonHeight;
	_color = newcolor;
	if ([newtext length])
		self.text = newtext;
	return self;
}

- (void)setText:(NSString *)newtext {
	text = newtext;

	CGPoint texorigin = font.texture.coords.origin;
	CGSize texsize = font.texture.coords.size;
	float hfactor = texsize.width / font.texture.width;
	float vfactor = texsize.height / font.texture.height;

	int length = (int)[text length];
	Buffer2DRect *buffer = malloc(length * sizeof(Buffer2DRect));

	CGPoint point = CGPointMake(0, 0);
	if (alignment == 1) {
		float textwidth = [font getWidthForString:text] * scale;
		float textheight = [font getHeightForString:text] * scale;
		point = CGPointMake(-textwidth/2, -textheight/2);
	}

	for (int i=0; i < length; i++) {
		Character2D chardef = font.charsArray[[text characterAtIndex:i]];  // TODO
		CGPoint newPoint = CGPointMake(point.x + chardef.xOffset * scale, point.y + (font.commonHeight - chardef.height - chardef.yOffset) * scale);

		/*buffer[i] = Buffer2DQuadMake(
			//Quad2 vertices = Quad2Make(newPoint.x, newPoint.y + charsArray[charID].height * scale, newPoint.x + charsArray[charID].width * scale, newPoint.y + charsArray[charID].height * scale, newPoint.x, newPoint.y, newPoint.x + charsArray[charID].width * scale, newPoint.y);
			// vertices
			roundf(newPoint.x), roundf(newPoint.y + chardef.height * scale),
			roundf(newPoint.x + chardef.width * scale), roundf(newPoint.y + chardef.height * scale),
			roundf(newPoint.x), roundf(newPoint.y),
			roundf(newPoint.x + chardef.width * scale), roundf(newPoint.y),
			// tex coords
			origin.x + chardef.x * hfactor, origin.y + size.height - chardef.y * vfactor,
			origin.x + (chardef.x+chardef.width) * hfactor, origin.y + size.height - chardef.y * vfactor,
			origin.x + chardef.x * hfactor, origin.y + size.height - (chardef.y+chardef.height) * vfactor,
			origin.x + (chardef.x+chardef.width) * hfactor, origin.y + size.height - (chardef.y+chardef.height) * vfactor);*/
		buffer[i] = Buffer2DRectMake(
			roundf(newPoint.x), roundf(newPoint.y), roundf(chardef.width * scale), roundf(chardef.height * scale),
			texorigin.x + chardef.x * hfactor, texorigin.y + texsize.height - (chardef.y + chardef.height) * vfactor, chardef.width * hfactor, chardef.height * vfactor);

		point.x += chardef.xAdvance * scale;
	}

	if (!buffer)
		buffer = ([[Buffer2D alloc] initWithMode:GL_TRIANGLES vertices:(Buffer2DVertex *) buffer vertexCount:length * 6 indices:nil indexCount:0 isDynamic:YES]);
	else
		[buffer updateVertices:(Buffer2DVertex *) buffer vertexCount:length * 6 indices:nil indexCount:0];

	free(buffer);
	buffer = nil;
}

- (void)draw {
	if (text && buffer) {
		/*CGPoint textposition;
		if (alignment == 1) {
			float textwidth = [font getWidthForString:text] * scale;
			float textheight = [font getHeightForString:text] * scale;
			textposition = CGPointMake(-textwidth/2, -textheight/2);
		} else
			textposition = CGPointMake(0, 0);
		[font drawStringAt:textposition text:text scale:scale];*/
		[font.texture bind];
		[super draw];
	}
}

@end
