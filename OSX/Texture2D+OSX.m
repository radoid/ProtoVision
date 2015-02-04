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
		/*glBindTexture(GL_TEXTURE_2D, name);
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
		}*/
		glBindTexture(GL_TEXTURE_2D, saveName);

		width = size.width / contentscale;
		height = size.height / contentscale;
		scale = contentscale;
		coords = CGRectMake(0, 0, size.width / (float)texturewidth, size.height / (float)textureheight);
	}
	return self;
}

- (void)dealloc {
	if (name) {
		NSLog(@"Brisemo name %d", name);
		glDeleteTextures(1, &name);
	}
}

- (NSString*)description {
	return [NSString stringWithFormat:@"<%@ = %8@ | Name = %i | Dimensions = %.0dx%.0d | Scale = %0.f | Coordinates = (%.2f, %.2f, %.2f x %.2f)>", [self class], self, name, width, height, scale, coords.origin.x, coords.origin.y, coords.size.width, coords.size.height];
}
/*
typedef struct {
	void *data;
	GLfloat width;
	GLfloat height;
} TextureData;

+ (TextureData)loadPngTexture:(NSString *)fileName {
	CFURLRef textureURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(),
												  (CFStringRef)fileName,
												  CFSTR("png"),
												  NULL);
	NSAssert(textureURL, @"Texture name invalid");

	CGImageSourceRef imageSource = CGImageSourceCreateWithURL(textureURL, NULL);
	NSAssert(imageSource, @"Invalid Image Path.");
	NSAssert((CGImageSourceGetCount(imageSource) > 0), @"No Image in Image Source.");
	CFRelease(textureURL);

	CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
	NSAssert(image, @"Image not created.");
	CFRelease(imageSource);

	GLuint width = CGImageGetWidth(image);
	GLuint height = CGImageGetHeight(image);

	void *data = malloc(width * height * 4);

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	NSAssert(colorSpace, @"Colorspace not created.");

	CGContextRef context = CGBitmapContextCreate(data,
												 width,
												 height,
												 8,
												 width * 4,
												 colorSpace,
												 kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host);
	NSAssert(context, @"Context not created.");

	CGColorSpaceRelease(colorSpace);
	// Flip so that it isn't upside-down
	CGContextTranslateCTM(context, 0, height);
	CGContextScaleCTM(context, 1.0f, -1.0f);
	CGContextSetBlendMode(context, kCGBlendModeCopy);
	CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
	CGImageRelease(image);
	CGContextRelease(context);

	return (TextureData) {data, width, height};
}
*/
- (id)initWithImageNamed:(NSString *)filename {
	if ((self = [super init])) {
		CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)[[NSBundle mainBundle] URLForImageResource:filename], NULL);
		NSAssert(imageSource, @"Image not found");
		CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
		CFRelease(imageSource);
		width  = CGImageGetWidth (image);
		height = CGImageGetHeight(image);
		CGRect rect = CGRectMake(0.0f, 0.0f, width, height);

		void *imageData = malloc(width * height * 4);
		CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef ctx = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colourSpace, kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
		CFRelease(colourSpace);

		CGContextTranslateCTM(ctx, 0, height);
		CGContextScaleCTM(ctx, 1.0f, -1.0f);

		CGContextSetBlendMode(ctx, kCGBlendModeCopy);
		CGContextDrawImage(ctx, rect, image);
		CGContextRelease(ctx);
		CFRelease(image);

		glGenTextures(1, &name);
		glBindTexture(GL_TEXTURE_2D, name);

		glPixelStorei(GL_UNPACK_ROW_LENGTH, (GLint)width);
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, (int)width, (int)height, 0, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, imageData);
		free(imageData);

		GLenum err; NSAssert(!(err = glGetError()), @"OpenGL error %x", err);
	}
	return self;
}

- (id)initWithImageNamed0:(NSString *)imagename {
	if ((self = [super init])) {
		NSImage *image = [NSImage imageNamed:imagename];
		if (!image) {
			NSLog(@"ERROR: Cannot load NSImage named \"%@\"", imagename);
			return nil;
		}

		NSBitmapImageRep* bitmap = [NSBitmapImageRep alloc];
		int samplesPerPixel = 0;
		NSSize imgSize = [image size];

		[image lockFocus];
		[bitmap initWithFocusedViewRect:NSMakeRect(0.0, 0.0, imgSize.width, imgSize.height)];
		[image unlockFocus];

		// Set proper unpacking row length for bitmap.
		glPixelStorei(GL_UNPACK_ROW_LENGTH, [bitmap pixelsWide]);

		// Set byte aligned unpacking (needed for 3 byte per pixel bitmaps).
		glPixelStorei (GL_UNPACK_ALIGNMENT, 1);

		// Nonplanar, RGB 24 bit bitmap, or RGBA 32 bit bitmap.
		samplesPerPixel = [bitmap samplesPerPixel];
		if (![bitmap isPlanar] && (samplesPerPixel == 3 || samplesPerPixel == 4)) {
			float contentscale = 1;
			//return [self initWithData:[bitmap bitmapData] pixelFormat:pixelFormat pixelsWide:texturewidth pixelsHigh:textureheight contentSize:imageSize contentScale:uiImage.scale];
			scale = contentscale;
			width = image.size.width / contentscale;
			height = image.size.height / contentscale;
			coords = CGRectMake(0, 0, 1, 1);

			glGenTextures(1, &name);
			glBindTexture(GL_TEXTURE_2D, name);

			// Non-mipmap filtering (redundant for texture_rectangle).
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,  GL_LINEAR);

			/*glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);*/

			glTexImage2D(GL_TEXTURE_2D, 0,
							 samplesPerPixel == 4 ? GL_RGBA8 : GL_RGB8,
							 [bitmap pixelsWide],
							 [bitmap pixelsHigh],
							 0,
							 samplesPerPixel == 4 ? GL_RGBA : GL_RGB,
							 GL_UNSIGNED_BYTE,
							 [bitmap bitmapData]);

			GLenum err = glGetError(); if (err) NSLog(@"[Texture2D init] OpenGL error %x", err);
		} else {
			// Handle other bitmap formats.
		}
	}
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
	if (name && name != current_name) {
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
		} while (p.location != NSNotFound && p2.location != NSNotFound);  // TODO p2.location is a garbage value?
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
