//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"

@class Texture2D, Light3D;


@interface Program3D : NSObject

@property (readonly) GLuint programname;
@property (readonly) GLint uProjection, uModel, uModelView, uNormalMatrix;
@property (readonly) GLint uLightCount, uLight, uEye, uTime;
@property (readonly) GLint uColor, uColorAmbient, uColorSpecular;
@property (readonly) GLint uUseColorMap, uColorMapSampler, uUseNormalMap, uNormalMapSampler, uUseSpecularMap, uSpecularMapSampler, uUseAmbientOcclusionMap, uAmbientOcclusionMapSampler;
@property (readonly) GLint aPosition, aNormal, aTangent;
@property (readonly) GLint uColorSize, aColor, aColorAmbient, aColorSpecular, aColorIndex;
@property (readonly) GLint aTextureUV;
@property (readonly) GLint uUseShadowMap, uShadowMatrix, uShadowMapSampler;

+ (id)defaultProgram;
+ (id)depthProgram;

- (void)use;

- (void)useWithProjection:(Matrix4x4)projection modelView:(Matrix4x4)modelview color:(Color2D)color texture:(Texture2D *)texture;
- (void)useWithProjection:(Matrix4x4)projection model:(Matrix4x4)model view:(Matrix4x4)view modelView:(Matrix4x4)modelview normal:(Matrix3x3)normal1 color:(Color2D)color colorAmbient:(Color2D)colorAmbient colorSpecular:(Color2D)colorSpecular colorSize:(int)colorSize colorMap:(Texture2D *)colorMap normalMap:(Texture2D *)normalMap specularMap:(Texture2D *)specularMap ambientOcclusionMap:(Texture2D *)ambientOcclusionMap light:(Light3D *)light eye:(Vector3D)eye;

- (void)useWithShadowMap:(FrameBuffer3D *)map projection:(Matrix4x4)projection view:(Matrix4x4)view;

+ (id)programNamed:(NSString *)filename;

- (id)initWithVertexShader:(NSString *)vss fragmentShader:(NSString *)fss;

@end
