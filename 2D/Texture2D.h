//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


typedef enum {
	kTexture2DPixelFormat_Automatic = 0,
	kTexture2DPixelFormat_RGBA8888,
	kTexture2DPixelFormat_RGB565,
	kTexture2DPixelFormat_A8,
} Texture2DPixelFormat;


@interface Texture2D : NSObject
{
	GLuint name;
	int width, height;
	CGRect coords;
	CGFloat scale;
	Texture2D *parent;
}
@property(readonly, nonatomic) GLuint name;
@property(readonly, nonatomic) int width, height;
@property(readonly, nonatomic) CGFloat scale;
@property(readonly, nonatomic) CGRect coords;

- (id)initWithImageNamed:(NSString *)imagename;

+ (void)unbind;
- (void)bind;

@end


@interface Texture2D (Atlas)
+ (void)loadImageMap:(NSString *)filename withImageNamed:(NSString *)imagename;
+ (void)unloadAll;
+ (Texture2D *)textureWithImageNamed:(NSString *)imagename;
- (id)initWithTexture:(Texture2D *)texture width:(int)newwidth height:(int)newheight coords:(CGRect)newcoords;
@end
