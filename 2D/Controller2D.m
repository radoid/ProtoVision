//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "Controller2D.h"


static Button2D *_button;


@implementation Controller2D

- (id)init {
	if ((self = [super init])) {
		stage = [[Container2D alloc] init];
	}
	return self;
}

- (void)setView:(View3D *)initview {
	_view = initview;
	[self reshape];
}

- (void)reshape {
	camera.frame = _view.frame;
}

- (void)resumeWithObject:(id)result {}

- (void)buttonPressed:(id)button {}

- (void)orientationDidChange:(float)angle offsetX:(int)offsetX offsetY:(int)offsetY width:(int)width height:(int)height {}

/*- (float)orientation {
	return stage.rotation;
}

- (void)setOrientation:(float)angle {
	stage.rotation = -angle;
	if (angle == +90)  // TODO
		stage.position = Vector2DMake(0, view.frame.size.height);
	else if (angle == -90)
		stage.position = Vector2DMake(view.frame.size.width, 0);
	else if (angle == 180)
		stage.position = Vector2DMake(view.frame.size.width, view.frame.size.height);
}*/

- (BOOL)touchDown:(Vector2D)location {
	Button2D *button = [stage findButtonAtLocation:Vector2DMultiply(location, camera.localToWorld)];
	if (button) {
		_button = button;
		_button.state = YES;
		//view.repainting = YES;
		return YES;
	}
	return NO;
}

- (BOOL)touchMove:(Vector2D)location {
	if (_button) {
		Button2D *button = [stage findButtonAtLocation:Vector2DMultiply(location, camera.localToWorld)];
		_button.state = (button == _button);
		//view.repainting = YES;
		return YES;
	}
	return NO;
}

- (BOOL)touchUp:(Vector2D)location {
	if (_button) {
		_button.state = NO;
		Button2D *button = [stage findButtonAtLocation:Vector2DMultiply(location, camera.localToWorld)];
		if (button == _button) {
			[self buttonPressed:_button];
		}
		_button = nil;
		//view.repainting = YES;
		return YES;
	}
	return NO;
}

- (void)draw {
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	[stage drawWithCamera:camera];
}

@end
