//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


@interface Image2D : Mesh2D <NSCopying>

@property (nonatomic) int width, height;

- (id)initWithImageNamed:(NSString *)imagename;
- (id)initWithImageNamed:(NSString *)imagename origin:(CGPoint)origin;
- (id)initWithImageNamed:(NSString *)imagename origin:(CGPoint)origin frame:(CGRect)frame stretch:(CGRect)stretch;

- (id)initWithTexture:(Texture2D *)texture;
- (id)initWithTexture:(Texture2D *)texture origin:(CGPoint)origin;
- (id)initWithTexture:(Texture2D *)texture origin:(CGPoint)origin frame:(CGRect)frame stretch:(CGRect)stretch;

@end
