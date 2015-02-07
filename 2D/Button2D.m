//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Button2D.h"


@implementation Button2D

@synthesize width, height, state=_state, text;

- (id)initWithImageNamed:(NSString *)imagename {
	return [self initWithImageNamed:imagename hoverImageNamed:imagename];
}

- (id)initWithImageNamed:(NSString *)normalimagename hoverImageNamed:(NSString *)hoverimagename {
	self = [super init];
	normalimage = [[Image2D alloc] initWithImageNamed:normalimagename];
	if ([hoverimagename isEqualToString:normalimagename])
		hoverimage = [normalimage copy];
	else
		hoverimage = [[Image2D alloc] initWithImageNamed:hoverimagename];
	[self add:normalimage];
	[self add:hoverimage];
	width = normalimage.width;
	height = normalimage.height;
	self._state = NO;
	return self;
}

- (id)initWithImageNamed:(NSString *)normalimagename hoverImageNamed:(NSString *)hoverimagename frame:(CGRect)frame stretch:(CGRect)stretch {
	self = [super init];
	_x = newframe.origin.x;
	_y = newframe.origin.y;
	width = newframe.size.width;
	height = newframe.size.height;
	normalimage = [[Image2D alloc] initWithImageNamed:normalimagename origin:CGPointZero frame:CGRectMake(0, 0, width, height) stretch:newstretch];
	if ([hoverimagename isEqualToString:normalimagename])
		hoverimage = [normalimage copy];
	else
		hoverimage = [[Image2D alloc] initWithImageNamed:hoverimagename origin:CGPointZero frame:CGRectMake(0, 0, width, height) stretch:newstretch];
	[self add:normalimage];
	[self add:hoverimage];
	self._state = NO;
	return self;
}

- (id)initWithImageNamed:(NSString *)normalimagename hoverImageNamed:(NSString *)hoverimagename frame:(CGRect)rect stretch:(CGRect)stretch text:(NSString *)newtext font:(Font2D *)newfont {
	self = [self initWithImageNamed:normalimagename hoverImageNamed:hoverimagename frame:rect stretch:stretch];
	float textwidth = [newfont getWidthForString:newtext];
	float textheight = [newfont getHeightForString:newtext];
	float textscale = rect.size.height / textheight;
	text = [[Text2D alloc] initWithFont:newfont text:newtext size:textscale * newfont.commonHeight color:Color2DMake(0, 0, 0, 1)];
	text.x = roundf((width - textwidth*textscale)/2);
	text.y = roundf((height - textheight*textscale)/2);
	[self add:text];
	return self;
}

- (void)setState:(BOOL)state {
	_state = state;
	normalimage.opacity = (_state ? 0.f : 1.f);
	hoverimage.opacity = (_state ? 1.f : 0.f);
	text.color = Color2DMake(_state ? 1 : 0.1, _state ? 1 : 0.1, _state ? 1 : 0.1, _color.alpha);
}

@end
