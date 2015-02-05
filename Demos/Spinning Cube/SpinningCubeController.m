//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "SpinningCubeController.h"


int main(int argc, const char * argv[]) {
	return [[[SpinningCubeController alloc] init] run];
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
	camera = [[Camera3D alloc] initWithPerspectivePosition:Vector3DMake(0, 0, 2) lookAt:Vector3DZero up:Vector3DY fovy:65 aspect:_view.frame.size.width / _view.frame.size.height near:0.1f far:20.f];
	light = [[Light3D alloc] initWithDirection:Vector3DMake(+0.5, 0, -0.5)];

	Box3D *box = [[Box3D alloc] initWithWidth:1 height:1 depth:1];
	box.x = -0.5;
	box.colorMap = [[Texture2D alloc] initWithImageNamed:@"colormap-box.jpg"];
	box.normalMap = [[Texture2D alloc] initWithImageNamed:@"normalmap-box.jpg"];
	//box.specularMap = [[Texture2D alloc] initWithImageNamed:@"specularmap-box.jpg"];
	box.colorAmbient = ColorRGBFromHSL(.17, .24, .3, 1);
	box.color = ColorRGBFromHSL(.14, .54, .76, 1);
	box.colorSpecular = ColorRGBFromHSL(.14, .54, .9, 1);
	box.program = [Program3D programNamed:@"specular"];
	[scene add:box];

	Sphere3D *sphere = [[Sphere3D alloc] initWithRadius:0.6 levels:50];
	sphere.position = Vector3DMake(0.7, 0, 0);
	sphere.colorAmbient = ColorRGBFromHSL(.47, .54, .1, 1);
	sphere.color = ColorRGBFromHSL(.44, .54, .86, 1);
	sphere.colorSpecular = ColorRGBFromHSL(.42, .54, .95, 1);
	sphere.specularMap = [[Texture2D alloc] initWithImageNamed:@"specularmap-box.jpg"];
	sphere.program = [Program3D programNamed:@"specular"];
	[scene add:sphere];

	/*for (int i=0; i < 20000; i++)
		[camera rotateAround:Vector3DZero byAxis:Vector3DY angle:+0.279765];
	for (int i=0; i < 20000; i++)
		[camera rotateAround:Vector3DZero byAxis:Vector3DY angle:-0.279765];*/

}

- (void)draw {
	[scene drawWithCamera:camera light:light];
}

/*- (BOOL)update:(float)delta {
	[camera rotateAround:Vector3DZero byAxis:Vector3DY angle:delta*90];
	return YES;
}*/

- (void)reshape {
	camera.aspect = _view.frame.size.width/_view.frame.size.height;
}

- (BOOL)touchDown:(Vector2D)location modifiers:(int)flags {
	dragging = location;
	dragging_position = camera.position;
	return NO;
}

- (BOOL)touchMove:(Vector2D)location modifiers:(int)flags {
	float radius = _view.frame.size.height/5;

	float angle = (dragging.x - location.x) / radius * 180/M_PI;
	[camera setPosition:Vector3DRotateByAxisAngle(dragging_position, Vector3DY, angle) lookAt:Vector3DZero up:Vector3DY];
	//camera.rotation = Quaternion3DMakeWithAxisAngle(Vector3DY, angle);
	//NSLog(@"%f", angle);

	/*float angle = (location.x - dragging.x) / radius * 180/M_PI;
	[scene rotateByAxis:camera.up angle:angle];
	angle = - (location.y - dragging.y) / radius * 180/M_PI;
	[scene rotateByAxis:camera.right angle:angle];

	/*Vector3D movement = { location.x - dragging.x, location.y - dragging.y, 0 };
	 Vector3D axis = Vector3DRotateWithAxisAngle(camera3d.up, camera3d.forward, - atan2f(movement.y, movement.x) * 180/M_PI);
	 float angle = Vector3DLength(movement) / radius / M_PI * 180;
	 [object rotateByAxis:axis angle:angle];*/

	//dragging = location;
	return YES;
}

@end
