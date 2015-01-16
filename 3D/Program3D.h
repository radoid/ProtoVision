//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


@interface Program3D : NSObject

@property (nonatomic, readonly) GLuint programname;
@property (nonatomic, readonly) GLint uProjection, uModelView, uNormal;
@property (nonatomic, readonly) GLint uColor, uColorLight, uColorDark, uLight, uEye, uTexture, uTexSampler;
@property (nonatomic, readonly) GLint aPosition, aNormal, aColor, aTexture;

+ (id)defaultProgram;
+ (id)defaultProgram2D;
+ (id)programNamed:(NSString *)filename;

- (id)initWithVertexShader:(NSString *)vss fragmentShader:(NSString *)fss;

@end
