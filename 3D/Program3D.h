//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"

@class Texture2D, Light3D;


@interface Program3D : NSObject

@property (nonatomic, readonly) GLuint programname;
@property (nonatomic, readonly) GLint uProjection, uModel, uModelView, uNormal;
@property (nonatomic, readonly) GLint uLightCount, uLight, uEye, uTime;
@property (nonatomic, readonly) GLint uColor, uColorAmbient, uColorSpecular;
@property (nonatomic, readonly) GLint uUseColorMap, uColorMapSampler, uUseNormalMap, uNormalMapSampler, uUseSpecularMap, uSpecularMapSampler, uUseAmbientOcclusionMap, uAmbientOcclusionMapSampler;
@property (nonatomic, readonly) GLint aPosition, aNormal, aTangent;
@property (nonatomic, readonly) GLint uColorSize, aColor, aColorAmbient, aColorSpecular, aColorIndex;
@property (nonatomic, readonly) GLint aTextureUV;

+ (id)defaultProgram;
+ (id)defaultProgram2D;

- (void)use;

- (void)useWithProjection:(Matrix4x4)projection model:(Matrix4x4)model view:(Matrix4x4)view modelView:(Matrix4x4)modelview normal:(Matrix3x3)normal1 color:(Color2D)color colorAmbient:(Color2D)colorAmbient colorSpecular:(Color2D)colorSpecular colorSize:(int)colorSize colorMap:(Texture2D *)colorMap normalMap:(Texture2D *)normalMap specularMap:(Texture2D *)specularMap ambientOcclusionMap:(Texture2D *)ambientOcclusionMap light:(Light3D *)light position:(Vector3D)position;

- (void)useWithProjection:(Matrix4x4)projection modelView:(Matrix4x4)modelview color:(Color2D)color texture:(Texture2D *)texture;

+ (id)programNamed:(NSString *)filename;

- (id)initWithVertexShader:(NSString *)vss fragmentShader:(NSString *)fss;

@end
