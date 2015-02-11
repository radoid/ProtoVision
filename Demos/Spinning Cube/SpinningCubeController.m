//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "SpinningCubeController.h"


int main(int argc, const char * argv[]) {
	return [[[SpinningCubeController alloc] init] runAnimated];
}


@implementation SpinningCubeController
{
	Container3D *scene;
	Camera3D *camera;
	Light3D *light;
	Vector2D dragging;
	Vector3D dragging_position;
}

- (void)start {
	scene = [[Container3D alloc] init];
	camera = [[Camera3D alloc] initWithPerspectivePosition:Vector3DMake(0, 0, .2) lookAt:Vector3DZero up:Vector3DY fovy:65 aspect:_view.frame.size.width / _view.frame.size.height near:0.01f far:10.f];
	light = [[Light3D alloc] initWithDirection:Vector3DMake(+1.5, 0, -0.5)];

	Cube3D *box = [[Cube3D alloc] initWithWidth:.1 height:.1 depth:.1];
	box.x = -0.05;
	//box.normalMap = [[Texture2D alloc] initWithImageNamed:@"test.png"];
	box.colorMap = [[Texture2D alloc] initWithImageNamed:@"colormap-box.jpg"];
	box.normalMap = [[Texture2D alloc] initWithImageNamed:@"normalmap-box.jpg"];
	//box.specularMap = [[Texture2D alloc] initWithImageNamed:@"specularmap-box.jpg"];
	//box.ambientOcclusionMap = [[Texture2D alloc] initWithImageNamed:@"ambientocclusionmap-box.jpg"];
	box.colorAmbient = Color2DFromHSL(.17, .24, .30, 1);
	box.colorDiffuse = Color2DFromHSL(.15, .34, .56, 1);
	box.colorSpecular = Color2DFromHSL(.14, .34, .95, 1);
	box.program = [Program3D programNamed:@"specular"];
	[scene add:box];

	Sphere3D *sphere = [[Sphere3D alloc] initWithRadius:0.06 levels:50];
	sphere.position = Vector3DMake(0.07, 0, 0);
	sphere.colorAmbient = Color2DFromHSL(.47, .54, .1, 1);
	sphere.color = Color2DFromHSL(.44, .54, .86, 1);
	sphere.colorSpecular = Color2DFromHSL(.42, .54, .95, 1);
	sphere.program = [Program3D programNamed:@"specular"];
	[scene add:sphere];

	//Line3D *line = [[Line3D alloc] initWithStart:Vector3DFlip(light.direction) end:Vector3DZero];
	//line.color = Color2DMake(1, .5, .5, 1);
	//[scene add:line];
}

- (void)draw {
	[scene drawWithCamera:camera light:light];
}

- (BOOL)update:(float)delta {
	[camera rotateAround:Vector3DZero byAxis:Vector3DY angle:delta*60];
	return YES;
}

- (void)reshape {
	camera.aspect = _view.frame.size.width/_view.frame.size.height;
}

- (BOOL)touchDown:(Vector2D)location modifiers:(int)flags {
	dragging = location;
	dragging_position = camera.position;
	return NO;
}

- (BOOL)touchMove:(Vector2D)location modifiers:(int)flags {
	float radius = _view.frame.size.height/5.;
	Vector3D movement = { location.x - dragging.x, location.y - dragging.y, 0 };
	float angle = Vector3DLength(movement) / radius / M_PI * 180;
	Vector3D axis = Vector3DRotateByAxisAngle(camera.up, camera.forward, - atan2f(movement.y, movement.x) * 180/M_PI);

	//[scene rotateByAxis:axis angle:angle];
	//[camera setPosition:Vector3DRotateByAxisAngle(dragging_position, axis, angle) lookAt:Vector3DZero up:camera.up];
	[camera rotateAround:Vector3DZero byAxis:axis angle:-angle];

	dragging = location;
	return YES;
}

@end
