//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"

@class Texture2D;


@interface Program3D : NSObject

@property (nonatomic, readonly) GLuint programname;
@property (nonatomic, readonly) GLint uProjection, uModelView, uNormal;
@property (nonatomic, readonly) GLint uColor, uColorLight, uColorDark, uLight, uEye, uTexture, uTexSampler, uTime;
@property (nonatomic, readonly) GLint aPosition, aNormal, aColor, aTexture;
@property (nonatomic, readonly) GLint uColorSize, aColorLight, aColorDark, aColorIndex;

+ (id)defaultProgram;
+ (id)defaultProgram2D;

- (void)use;

- (void)useWithProjection:(Matrix4x4)projection modelView:(Matrix4x4)modelview normal:(Matrix3x3)normal color:(Color2D)color texture:(Texture2D *)texture light:(Vector3D)direction position:(Vector3D)position;

- (void)useWithProjection:(Matrix4x4)projection modelView:(Matrix4x4)modelview normal:(Matrix3x3)normal colorDark:(Color2D)colorDark colorLight:(Color2D)colorLight colorSize:(int)colorSize texture:(Texture2D *)texture light:(Vector3D)direction position:(Vector3D)position;

- (void)useWithProjection:(Matrix4x4)projection modelView:(Matrix4x4)modelview color:(Color2D)color texture:(Texture2D *)texture;

+ (id)programNamed:(NSString *)filename;

- (id)initWithVertexShader:(NSString *)vss fragmentShader:(NSString *)fss;

@end
