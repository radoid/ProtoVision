//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


@interface Image2D : Mesh2D <NSCopying>
{
	int width, height;
}
@property (nonatomic) int width, height;

- (id)initWithImageNamed:(NSString *)imagename;
- (id)initWithImageNamed:(NSString *)imagename origin:(CGPoint)neworigin;
- (id)initWithImageNamed:(NSString *)imagename origin:(CGPoint)neworigin frame:(CGRect)newframe stretch:(CGRect)newstretch;

- (id)initWithTexture:(Texture2D *)newtexture;
- (id)initWithTexture:(Texture2D *)newtexture origin:(CGPoint)neworigin;
- (id)initWithTexture:(Texture2D *)newtexture origin:(CGPoint)neworigin frame:(CGRect)newframe stretch:(CGRect)newstretch;

@end
