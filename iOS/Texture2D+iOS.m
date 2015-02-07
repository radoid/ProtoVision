//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Texture2D.h"

#define kMaxTextureSize	 2048


@implementation Texture2D

@synthesize name, width, height, scale, coords;


- (id)initWithData:(const void*)data pixelFormat:(Texture2DPixelFormat)pixelFormat pixelsWide:(NSUInteger)texturewidth pixelsHigh:(NSUInteger)textureheight contentSize:(CGSize)size contentScale:(CGFloat)contentscale {
	GLint saveName;
	if((self = [super init])) {
		glGenTextures(1, &name);
		glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
		glBindTexture(GL_TEXTURE_2D, name);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		switch(pixelFormat) {
			case kTexture2DPixelFormat_RGBA8888:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texturewidth, textureheight, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
				break;
			case kTexture2DPixelFormat_RGB565:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, texturewidth, textureheight, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, data);
				break;
			case kTexture2DPixelFormat_A8:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, texturewidth, textureheight, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data);
				break;
			default:
				[NSException raise:NSInternalInconsistencyException format:@""];
		}
		glBindTexture(GL_TEXTURE_2D, saveName);

		width = size.width / contentscale;
		height = size.height / contentscale;
		scale = contentscale;
		coords = CGRectMake(0, 0, size.width / (float)texturewidth, size.height / (float)textureheight);
	}
	return self;
}

- (void)dealloc {
	if (name)
		glDeleteTextures(1, &name);
}

- (NSString*)description {
	return [NSString stringWithFormat:@"<%@ = %8@ | Name = %i | Dimensions = %dx%d | Scale = %0.f | Coordinates = (%.2f, %.2f, %.2f x %.2f)>", [self class], self, name, width, height, scale, coords.origin.x, coords.origin.y, coords.size.width, coords.size.height];
}

- (id)initWithImageNamed:(NSString *)imagename {
	NSUInteger textureheight, texturewidth, i;
	CGContextRef			context = nil;
	void*					data = nil;;
	CGColorSpaceRef			colorSpace;
	void*					tempData;
	unsigned int*			inPixel32;
	unsigned short*			outPixel16;
	BOOL					hasAlpha;
	CGImageAlphaInfo		info;
	CGAffineTransform		transform;
	CGSize					imageSize;
	Texture2DPixelFormat    pixelFormat;
	BOOL					sizeToFit = NO;

	UIImage *uiImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imagename ofType:@"png"]];
	if (!uiImage) {
		NSLog(@"ERROR: Cannot load UIImage named \"%@\"", imagename);
		return nil;
	}

	CGImageRef image = [uiImage CGImage];
	if (!image) {
		NSLog(@"ERROR: Image is Null");
		return nil;
	}

	info = CGImageGetAlphaInfo(image);
	hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
	if(CGImageGetColorSpace(image)) {
		if(hasAlpha)
			pixelFormat = kTexture2DPixelFormat_RGBA8888;
		else
			pixelFormat = kTexture2DPixelFormat_RGB565;
	} else  //NOTE: No colorspace means a mask image
		pixelFormat = kTexture2DPixelFormat_A8;

	imageSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
	transform = CGAffineTransformIdentity;

	texturewidth = imageSize.width;

	if((texturewidth != 1) && (texturewidth & (texturewidth - 1))) {
		i = 1;
		while((sizeToFit ? 2 * i : i) < texturewidth)
			i *= 2;
		texturewidth = i;
	}
	textureheight = imageSize.height;
	if((textureheight != 1) && (textureheight & (textureheight - 1))) {
		i = 1;
		while((sizeToFit ? 2 * i : i) < textureheight)
			i *= 2;
		textureheight = i;
	}
	while((texturewidth > kMaxTextureSize) || (textureheight > kMaxTextureSize)) {
		texturewidth /= 2;
		textureheight /= 2;
		transform = CGAffineTransformScale(transform, 0.5, 0.5);
		imageSize.width *= 0.5;
		imageSize.height *= 0.5;
	}

	switch(pixelFormat) {
		case kTexture2DPixelFormat_RGBA8888:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(textureheight * texturewidth * 4);
			context = CGBitmapContextCreate(data, texturewidth, textureheight, 8, 4 * texturewidth, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
		case kTexture2DPixelFormat_RGB565:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(textureheight * texturewidth * 4);
			context = CGBitmapContextCreate(data, texturewidth, textureheight, 8, 4 * texturewidth, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
		case kTexture2DPixelFormat_A8:
			data = malloc(textureheight * texturewidth);
			context = CGBitmapContextCreate(data, texturewidth, textureheight, 8, texturewidth, NULL, kCGImageAlphaOnly);
			break;
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
	}

	CGContextClearRect(context, CGRectMake(0, 0, texturewidth, textureheight));
	CGContextTranslateCTM(context, 0, textureheight); // Ante
	CGContextScaleCTM(context, 1, -1); // Ante
	//CGContextTranslateCTM(context, 0, height - imageSize.height);

	if(!CGAffineTransformIsIdentity(transform))
		CGContextConcatCTM(context, transform);
	CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
	if(pixelFormat == kTexture2DPixelFormat_RGB565) {
		tempData = malloc(textureheight * texturewidth * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < texturewidth * textureheight; ++i, ++inPixel32)
			*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
		free(data);
		data = tempData;

	}

	self = [self initWithData:data pixelFormat:pixelFormat pixelsWide:texturewidth pixelsHigh:textureheight contentSize:imageSize contentScale:uiImage.scale];

	CGContextRelease(context);
	free(data);

	return self;
}

/*
@implementation Texture2D (Text)

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	NSUInteger				width,
							height,
							i;
	CGContextRef			context;
	void*					data;
	CGColorSpaceRef			colorSpace;
	UIFont *				font;

	font = [UIFont fontWithName:name size:size];

	width = dimensions.width;
	if((width != 1) && (width & (width - 1))) {
		i = 1;
		while(i < width)
		i *= 2;
		width = i;
	}
	height = dimensions.height;
	if((height != 1) && (height & (height - 1))) {
		i = 1;
		while(i < height)
		i *= 2;
		height = i;
	}

	colorSpace = CGColorSpaceCreateDeviceGray();
	data = calloc(height, width);
	context = CGBitmapContextCreate(data, width, height, 8, width, colorSpace, kCGImageAlphaNone);
	CGColorSpaceRelease(colorSpace);


	CGContextSetGrayFillColor(context, 1.0, 1.0);
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0); //NOTE: NSString draws in UIKit referential i.e. renders upside-down compared to CGBitmapContext referential
	UIGraphicsPushContext(context);
	[string drawInRect:CGRectMake(0, 0, dimensions.width, dimensions.height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:alignment];
	UIGraphicsPopContext();

	self = [self initWithData:data pixelFormat:kTexture2DPixelFormat_A8 pixelsWide:width pixelsHigh:height contentSize:dimensions];

	CGContextRelease(context);
	free(data);

	return self;
}

@end
*/


static int current_name = 0;

+ (void)unbind {
	current_name = 0;
	glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)bind {
	if (name != current_name) {
		glBindTexture(GL_TEXTURE_2D, name);
		//NSLog(@"[Texture2D bind] Bindana tekstura %d", name);
		GLenum err = glGetError(); if (err) NSLog(@"[Texture2D bind] OpenGL error %x", err);
		current_name = name;
	}
}
/*
- (void)draw {
	//[self drawAtPoint:CGPointMake(0, 0)];
	[self bind];

	if (!vbo) {
		Buffer2DVertex buffer[] = {
			0.0, 0.0, coords.origin.x, coords.origin.y,
			width, 0.0, coords.origin.x + coords.size.width, coords.origin.y,
			0.0, height, coords.origin.x, coords.origin.y + coords.size.height,
			width, height, coords.origin.x + coords.size.width, coords.origin.y + coords.size.height };
		vbo = [[Buffer2D alloc] initWithMode:GL_TRIANGLE_STRIP vertexBuffer:buffer vertexCount:sizeof(buffer)/sizeof(Buffer2DVertex) indexBuffer:nil indexCount:0 isDynamic:NO];
	}
	[vbo draw];
}

- (void) drawAtPoint:(CGPoint)point {
	GLfloat vertices[] = {	point.x,	point.y,	0.0,
		width + point.x,	point.y,	0.0,
		point.x,	height + point.y,	0.0,
		width + point.x,	height + point.y,	0.0 };
	GLfloat realcoords[] = {
		coords.origin.x, coords.origin.y,
		coords.origin.x + coords.size.width, coords.origin.y,
		coords.origin.x, (coords.origin.y + coords.size.height),
		coords.origin.x + coords.size.width, (coords.origin.y + coords.size.height) };

	[self bind];
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, realcoords);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void) drawInRect:(CGRect)rect {
	GLfloat vertices[] = {
		rect.origin.x, rect.origin.y, 0.0,
		rect.origin.x + rect.size.width, rect.origin.y, 0.0,
		rect.origin.x, rect.origin.y + rect.size.height, 0.0,
		rect.origin.x + rect.size.width, rect.origin.y + rect.size.height, 0.0 };
	GLfloat realcoords[] = {
		coords.origin.x, coords.origin.y,
		coords.origin.x + coords.size.width, coords.origin.y,
		coords.origin.x, (coords.origin.y + coords.size.height),
		coords.origin.x + coords.size.width, (coords.origin.y + coords.size.height) };

	[self bind];
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, realcoords);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void) drawInRect:(CGRect)rect coords:(CGRect)subcoords {
	GLfloat vertices[] = {
		rect.origin.x, rect.origin.y, 0.0,
		rect.origin.x + rect.size.width, rect.origin.y,	 0.0,
		rect.origin.x, rect.origin.y + rect.size.height, 0.0,
		rect.origin.x + rect.size.width, rect.origin.y + rect.size.height, 0.0 };
	GLfloat realcoords[] = {
		subcoords.origin.x, subcoords.origin.y,
		subcoords.origin.x + subcoords.size.width, subcoords.origin.y,
		subcoords.origin.x, (subcoords.origin.y + subcoords.size.height),
		subcoords.origin.x + subcoords.size.width, (subcoords.origin.y + subcoords.size.height) };

	[self bind];
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, realcoords);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}*/
@end



static NSMutableDictionary *atlasDictionary;

@implementation Texture2D (Atlas)

+ (void)loadImageMap:(NSString *)filename withImageNamed:(NSString *)imagename {
//	@synchronized (atlasDictionary) {
		if (!atlasDictionary)
			atlasDictionary = [[NSMutableDictionary alloc] init];

		NSString *contents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"htm"] encoding:NSASCIIStringEncoding error:nil];
		if (!contents) {
			NSLog(@"ERROR: Ne mogu ucitati imagemap \"%@.htm\"!!", filename);
			return;
		}

		Texture2D *atlas = [[Texture2D alloc] initWithImageNamed:imagename];
		if (!atlas) {
			NSLog(@"ERROR: Ne mogu ucitati teksturu atlasa \"%.png\"@!!", imagename);
			return;
		}
		[atlasDictionary setObject:atlas forKey:filename];

		NSRange p, p2;
		do {
			p = [contents rangeOfString:@"<AREA" options:NSCaseInsensitiveSearch];
			if (p.location != NSNotFound) {
				//NSLog(@"<area na mjestu %d", p.location);
				contents = [contents substringFromIndex:p.location+5];
				p = [contents rangeOfString:@" HREF=\"" options:NSCaseInsensitiveSearch];
				if (p.location != NSNotFound) {
					//NSLog(@"href= na mjestu %d", p.location);
					contents = [contents substringFromIndex:p.location+7];
					p = [contents rangeOfString:@"\"" options:NSCaseInsensitiveSearch];
					if (p.location != NSNotFound) {
						NSString *name = [contents substringWithRange:NSMakeRange(0, p.location)];
						contents = [contents substringFromIndex:p.location+1];
						//NSLog(@"suptekstura %@", name);
						p = [contents rangeOfString:@" COORDS=\"" options:NSCaseInsensitiveSearch];
						if (p.location != NSNotFound) {
							//NSLog(@"COORDS= na mjestu %d", p.location);
							contents = [contents substringFromIndex:p.location+9];
							p = [contents rangeOfString:@"\"" options:NSCaseInsensitiveSearch];
							if (p.location != NSNotFound) {
								NSString *coords = [contents substringWithRange:NSMakeRange(0, p.location)];
								contents = [contents substringFromIndex:p.location+1];
								//NSLog(@"Subtekstura %@ ima koordinate %@", name, coords);
								NSArray *coords_array = [coords componentsSeparatedByString:@","];
								//NSLog(@"Subtekstura %@ ima %d koordinata", name, [coords_array count]);
								if ([coords_array count] == 4) {
									CGRect rect = CGRectMake([(NSString *)[coords_array objectAtIndex:0] floatValue], atlas.height - [(NSString *)[coords_array objectAtIndex:3] floatValue], [(NSString *)[coords_array objectAtIndex:2] floatValue] - [(NSString *)[coords_array objectAtIndex:0] floatValue], [(NSString *)[coords_array objectAtIndex:3] floatValue] - [(NSString *)[coords_array objectAtIndex:1] floatValue]);
									CGSize size = rect.size;
									rect = CGRectMake(
										rect.origin.x / atlas.width * atlas.coords.size.width,
										rect.origin.y / atlas.height * atlas.coords.size.height,
										(rect.size.width) / atlas.width * atlas.coords.size.width,
										(rect.size.height) / atlas.height * atlas.coords.size.height);
									Texture2D *subtexture = [[Texture2D alloc] initWithTexture:atlas width:size.width height:size.height coords:rect];
									[atlasDictionary setObject:subtexture forKey:name];
								}
							}
						}
					}
				}
			}
		} while (p.location != NSNotFound && p2.location != NSNotFound);
//	}
}

+ (void)unloadAll {
//	@synchronized (atlasDictionary) {
		atlasDictionary = nil;
//	}
}

+ (Texture2D *)textureWithImageNamed:(NSString *)imagename {
	if (!atlasDictionary)
		atlasDictionary = [[NSMutableDictionary alloc] init];
	Texture2D *twin = [atlasDictionary objectForKey:imagename];
	if (twin)
		return twin;
	twin = [[Texture2D alloc] initWithImageNamed:imagename];
	if (twin)
		[atlasDictionary setObject:twin forKey:imagename];
	return twin;
}

- (id)initWithTexture:(Texture2D *)texture width:(int)newwidth height:(int)newheight coords:(CGRect)newcoords {
	if ((self = [super init])) {
		parent = texture;
		name = texture.name;
		scale = texture.scale;
		width = newwidth;
		height = newheight;
		coords = newcoords;
	}
	return self;
}

@end
