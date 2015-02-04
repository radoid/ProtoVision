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
@property (nonatomic, readonly) GLint uEye, uLight, uTime;
@property (nonatomic, readonly) GLint uColor, uColorAmbient;
@property (nonatomic, readonly) GLint uUseColorMap, uColorMapSampler, uUseNormalMap, uNormalMapSampler;
@property (nonatomic, readonly) GLint aPosition, aNormal, aTangent;
@property (nonatomic, readonly) GLint uColorSize, aColor, aColorAmbient, aColorIndex;
@property (nonatomic, readonly) GLint aTextureUV, aNormalMapUV;

+ (id)defaultProgram;
+ (id)defaultProgram2D;

- (void)use;

- (void)useWithProjection:(Matrix4x4)projection modelView:(Matrix4x4)modelview normal:(Matrix3x3)normal color:(Color2D)color texture:(Texture2D *)texture light:(Vector3D)direction position:(Vector3D)position;

- (void)useWithProjection:(Matrix4x4)projection modelView:(Matrix4x4)modelview normal:(Matrix3x3)normal colorAmbient:(Color2D)colorAmbient color:(Color2D)color colorSize:(int)colorSize colorMap:(Texture2D *)colorMap normalMap:(Texture2D *)normalMap light:(Vector3D)direction position:(Vector3D)position;

- (void)useWithProjection:(Matrix4x4)projection modelView:(Matrix4x4)modelview color:(Color2D)color texture:(Texture2D *)texture;

+ (id)programNamed:(NSString *)filename;

- (id)initWithVertexShader:(NSString *)vss fragmentShader:(NSString *)fss;

@end
