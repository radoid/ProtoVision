//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


@interface Button2D : Container2D {
	float width, height;
	BOOL _state;
	//NSString *text;
	//Font2D *font;
	Text2D *text;
	//CGPoint textposition;
	//float textscale;
	//Texture2D *normaltexture, *hovertexture;
	Image2D *normalimage, *hoverimage;
	//int radius;
}
@property (nonatomic, setter=setState:) BOOL state;
@property (nonatomic, readonly) float width, height;
@property (nonatomic, retain) Text2D *text;

- (id)initWithImageNamed:(NSString *)imagename;
- (id)initWithImageNamed:(NSString *)normalimagename hoverImageNamed:(NSString *)hoverimagename;
- (id)initWithImageNamed:(NSString *)normalimagename hoverImageNamed:(NSString *)hoverimagename frame:(CGRect)rect stretch:(CGRect)stretch;
- (id)initWithImageNamed:(NSString *)normalimagename hoverImageNamed:(NSString *)hoverimagename frame:(CGRect)rect stretch:(CGRect)stretch text:(NSString *)text font:(Font2D *)font;

@end
