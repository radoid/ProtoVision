//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Image2D.h"


@interface Image2D (Copying)
- (id)initWithTexture:(Texture2D *)newtexture origin:(CGPoint)neworigin frame:(CGRect)newframe stretch:(CGRect)newstretch buffer:(Buffer2D *)newvbo;
- (id)copyWithZone:(NSZone *)zone;
@end


@implementation Image2D

@synthesize width, height;

- (id)initWithImageNamed:(NSString *)imagename {
	return [self initWithImageNamed:imagename origin:CGPointMake(0, 0) frame:CGRectZero stretch:CGRectZero];
}

- (id)initWithImageNamed:(NSString *)imagename origin:(CGPoint)neworigin {
	return [self initWithImageNamed:imagename origin:neworigin frame:CGRectZero stretch:CGRectZero];
}

- (id)initWithImageNamed:(NSString *)imagename origin:(CGPoint)neworigin frame:(CGRect)newframe stretch:(CGRect)newstretch {
	Texture2D *newtexture = [Texture2D textureWithImageNamed:imagename];
	if (!newtexture) {
		NSLog(@"ERROR: Subtexture \"%@\" failed for Image2D!", imagename);
		return nil;
	}
	return [self initWithTexture:newtexture origin:neworigin frame:newframe stretch:newstretch];
}

- (id)initWithTexture:(Texture2D *)newtexture {
	return [self initWithTexture:newtexture origin:CGPointMake(0, 0) frame:CGRectZero stretch:CGRectZero];
}

- (id)initWithTexture:(Texture2D *)newtexture origin:(CGPoint)neworigin {
	return [self initWithTexture:newtexture origin:neworigin frame:CGRectZero stretch:CGRectZero];
}

- (id)initWithTexture:(Texture2D *)newtexture origin:(CGPoint)neworigin frame:(CGRect)newframe stretch:(CGRect)newstretch {
	return [self initWithTexture:newtexture origin:neworigin frame:newframe stretch:newstretch buffer:nil];
}

- (id)initWithTexture:(Texture2D *)newtexture origin:(CGPoint)neworigin frame:(CGRect)newframe stretch:(CGRect)newstretch buffer:(Buffer2D *)newvbo{
	if ((self = [super init])) {
		_texture = newtexture;
		_origin = neworigin;
		_x = (newframe.size.width && newframe.size.height ? newframe.origin.x : 0);
		_y = (newframe.size.width && newframe.size.height ? newframe.origin.y : 0);
		width = (newframe.size.width && newframe.size.height ? newframe.size.width : _texture.width);
		height = (newframe.size.width && newframe.size.height ? newframe.size.height : _texture.height);
		CGRect stretch = newstretch;
		if (stretch.size.width < 0)
			stretch.size.width = _texture.width + stretch.size.width - stretch.origin.x;
		if (stretch.size.height < 0)
			stretch.size.height = _texture.height + stretch.size.height - stretch.origin.y;

		if (stretch.size.width > 0 && stretch.size.height > 0 && (stretch.size.width < width || stretch.size.height < height)) {
			/*CGPoint p1 = stretch.origin;
			CGPoint p2 = CGPointMake(stretch.origin.x + stretch.size.width + (width - texture.width), stretch.origin.y + stretch.size.height + (height - texture.height));
			CGPoint coord0 = texture.coords.origin;
			CGPoint coord1 = CGPointMake(texture.coords.origin.x + stretch.origin.x * texture.coords.size.width / texture.width, texture.coords.origin.y + stretch.origin.y * texture.coords.size.height / texture.height);
			CGPoint coord2 = CGPointMake(texture.coords.origin.x + (stretch.origin.x + stretch.size.width) * texture.coords.size.width / texture.width, texture.coords.origin.y + (stretch.origin.y + stretch.size.height) * texture.coords.size.height / texture.height);
			CGPoint coord3 = CGPointMake(texture.coords.origin.x + texture.coords.size.width, texture.coords.origin.y + texture.coords.size.height);

			Buffer2DVertex vertices[] = {
				0, height, coord0.x, coord3.y,
				p1.x, height, coord1.x, coord3.y,
				p2.x, height, coord2.x, coord3.y,
				width, height, coord3.x, coord3.y,

				0, p2.y, coord0.x, coord2.y,
				p1.x, p2.y, coord1.x, coord2.y,
				p2.x, p2.y, coord2.x, coord2.y,
				width, p2.y, coord3.x, coord2.y,

				0, p1.y, coord0.x, coord1.y,
				p1.x, p1.y, coord1.x, coord1.y,
				p2.x, p1.y, coord2.x, coord1.y,
				width, p1.y, coord3.x, coord1.y,

				0, 0, coord0.x, coord0.y,
				p1.x, 0, coord1.x, coord0.y,
				p2.x, 0, coord2.x, coord0.y,
				width, 0, coord3.x, coord0.y };*/

			CGRect coords = _texture.coords;
			CGRect subcoords = CGRectMake(coords.origin.x + stretch.origin.x * coords.size.width / _texture.width, coords.origin.y + stretch.origin.y * coords.size.height / _texture.height, stretch.size.width * coords.size.width / _texture.width, stretch.size.height * coords.size.height / _texture.height);
			CGRect subframe = CGRectMake(stretch.origin.x, stretch.origin.y, stretch.size.width + (width - _texture.width), stretch.size.height + (height - _texture.height));

			GLfloat vertices[] = {
				0, height, coords.origin.x, coords.origin.y + coords.size.height,
				subframe.origin.x, height, subcoords.origin.x, coords.origin.y + coords.size.height,
				subframe.origin.x + subframe.size.width, height, subcoords.origin.x + subcoords.size.width, coords.origin.y + coords.size.height,
				width, height, coords.origin.x + coords.size.width, coords.origin.y + coords.size.height,

				0, subframe.origin.y + subframe.size.height, coords.origin.x, subcoords.origin.y + subcoords.size.height,
				subframe.origin.x, subframe.origin.y + subframe.size.height, subcoords.origin.x, subcoords.origin.y + subcoords.size.height,
				subframe.origin.x + subframe.size.width, subframe.origin.y + subframe.size.height, subcoords.origin.x + subcoords.size.width, subcoords.origin.y + subcoords.size.height,
				width, subframe.origin.y + subframe.size.height, coords.origin.x + coords.size.width, subcoords.origin.y + subcoords.size.height,

				0, subframe.origin.y, coords.origin.x, subcoords.origin.y,
				subframe.origin.x, subframe.origin.y, subcoords.origin.x, subcoords.origin.y,
				subframe.origin.x + subframe.size.width, subframe.origin.y, subcoords.origin.x + subcoords.size.width, subcoords.origin.y,
				width, subframe.origin.y, coords.origin.x + coords.size.width, subcoords.origin.y,

				0, 0, 0, coords.origin.x, coords.origin.y,
				subframe.origin.x, 0, 0, subcoords.origin.x, coords.origin.y,
				subframe.origin.x + subframe.size.width, 0, 0, subcoords.origin.x + subcoords.size.width, coords.origin.y,
				width, 0, 0, coords.origin.x + coords.size.width, coords.origin.y };

			GLushort indices[] = {
				0, 4, 1, 5, 2, 6, 3, 7, 7,
				4, 4, 8, 5, 9, 6, 10, 7, 11, 11,
				8, 8, 12, 9, 13, 10, 14, 11, 15 };

			return [self initWithMode:GL_TRIANGLE_STRIP vertices:vertices vertexCount:sizeof(vertices)/sizeof(GLfloat)/5 indices:indices indexCount:sizeof(indices)/sizeof(GLushort) vertexSize:3 texCoordsSize:2 colorSize:0 isDynamic:NO];
		}
		else {
			//GLfloat vertices[] = {
			//	0.0, 0.0, 0, texture.coords.origin.x, texture.coords.origin.y,
			//	width, 0.0, 0, texture.coords.origin.x + texture.coords.size.width, texture.coords.origin.y,
			//	0.0, height, 0, texture.coords.origin.x, texture.coords.origin.y + texture.coords.size.height,
			//	width, height, 0, texture.coords.origin.x + texture.coords.size.width, texture.coords.origin.y + texture.coords.size.height };

			GLfloat vertices[] = {
				0.0, 0.0, 0, 0, 0,
				width, 0.0, 0, newframe.size.width / _texture.width, 0,
				0.0, height, 0, 0, newframe.size.height / _texture.height,
				width, height, 0, newframe.size.width / _texture.width, newframe.size.height / _texture.height };

			return [self initWithMode:GL_TRIANGLE_STRIP vertices:vertices vertexCount:sizeof(vertices)/sizeof(GLfloat)/5 indices:nil	 indexCount:0 vertexSize:3 texCoordsSize:2 colorSize:0 isDynamic:NO];
		}

	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	Image2D *copy = [super copyWithZone:zone];
	copy.width = width;
	copy.height = height;
	//return [[Image2D allocWithZone:zone] initWithTexture:texture origin:_origin frame:CGRectMake(x, y, width, height) stretch:CGRectZero buffer:buffer];
	return copy;
}

@end
