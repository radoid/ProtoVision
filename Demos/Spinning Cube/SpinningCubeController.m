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
}

- (void)start {
	scene = [[Container3D alloc] init];
	//camera = [[Camera3D alloc] initWithPerspectivePosition:Vector3DMake(1.5, 1, 1) lookAt:Vector3DZero up:Vector3DY fovy:65 aspect:_view.frame.size.width / _view.frame.size.height near:0.1f far:20.f];
	camera = [[Camera3D alloc] initWithPerspectivePosition:Vector3DMake(0, 0, 2) lookAt:Vector3DZero up:Vector3DY fovy:65 aspect:_view.frame.size.width / _view.frame.size.height near:0.1f far:20.f];
	//camera = [[Camera3D alloc] initWithPerspectivePosition:Vector3DMake(0, 2, 0) lookAt:Vector3DZero up:Vector3DZFlip fovy:65 aspect:_view.frame.size.width / _view.frame.size.height near:0.1f far:20.f];
	light = [[Light3D alloc] initWithDirection:Vector3DMake(+0.5, -1, -0.5)];

	Box3D *box = [[Box3D alloc] initWithWidth:1 height:1 depth:1];
	box.x = -0.5;
	//box.texture = [[Texture2D alloc] initWithImageNamed:@"normalmap-10pence.jpg"];
	//box.texture = [[Texture2D alloc] initWithImageNamed:@"normalmap-10pence2.jpg"];
	//box.texture = [[Texture2D alloc] initWithImageNamed:@"normalmap-dots.png"];
	box.colorMap = [[Texture2D alloc] initWithImageNamed:@"blender.jpg"];
	box.program = [Program3D programNamed:@"normalmap"];
	[scene add:box];

	Disc3D *head = [[Disc3D alloc] initWithRadius:1/2. height:.01 levels:50];
	head.position = Vector3DMake(+0.5, 0, +0.005);
	head.rotation = Quaternion3DMakeWithAxisAngle(Vector3DX, 90);
	head.color = ColorRGBFromHSL(.14, .54, .76, 1);
	head.colorAmbient = ColorRGBFromHSL(.14, .44, .26, 1);
	head.normalMap = [[Texture2D alloc] initWithImageNamed:@"normalmap-10pence2.jpg"];
	head.program = [Program3D programNamed:@"normalmap"];
	[scene add:head];

	Disc3D *tails = [[Disc3D alloc] initWithRadius:1/2. height:.01 levels:50];
	tails.position = Vector3DMake(+0.5, 0, -0.005);
	tails.rotation = Quaternion3DMakeWithAxisAngle(Vector3DX, 90);
	[tails rotateByAxis:Vector3DY angle:180];
	tails.color = ColorRGBFromHSL(.14, .54, .66, 1);
	tails.colorAmbient = ColorRGBFromHSL(.14, .44, .16, 1);
	tails.normalMap = [[Texture2D alloc] initWithImageNamed:@"normalmap-10pence.jpg"];
	tails.program = [Program3D programNamed:@"normalmap"];
	[scene add:tails];

	Sphere3D *sphere = [[Sphere3D alloc] initWithRadius:0.5 levels:50];
	sphere.position = Vector3DMake(0, 0.5, -0.5);
	sphere.colorAmbient = Color2DMake(.22, .54, .16, 1);
	sphere.color = Color2DMake(.25, .54, .56, 1);
	[scene add:sphere];
	//disc.normalMap = [[Texture2D alloc] initWithImageNamed:@"normalmap-dots.png"];
	//disc.normalMap = [[Texture2D alloc] initWithImageNamed:@"normalmap-coin.jpg"];

	//Image2D *box2d = [[Image2D alloc] initWithImageNamed:@"normalmap-10pence2.jpg"];
	//[scene add:box2d];
}

- (void)draw {
	[scene drawWithCamera:camera light:light];
}
/*
- (BOOL)update:(float)delta {
	[camera rotateAround:Vector3DZero byAxis:Vector3DY angle:delta*90];
	return YES;
}*/

- (void)reshape {
	camera.aspect = _view.frame.size.width/_view.frame.size.height;
}

- (BOOL)touchDown:(Vector2D)location modifiers:(int)flags {
	dragging = location;
	return NO;
}

- (BOOL)touchMove:(Vector2D)location modifiers:(int)flags {
	float radius = _view.frame.size.height/5;
	Object3D *object = [scene.children lastObject];

	float angle = (location.x - dragging.x) / radius * 180/M_PI;
	[scene rotateByAxis:camera.up angle:angle];
	angle = - (location.y - dragging.y) / radius * 180/M_PI;
	[scene rotateByAxis:camera.right angle:angle];

	/*Vector3D movement = { location.x - dragging.x, location.y - dragging.y, 0 };
	 Vector3D axis = Vector3DRotateWithAxisAngle(camera3d.up, camera3d.forward, - atan2f(movement.y, movement.x) * 180/M_PI);
	 float angle = Vector3DLength(movement) / radius / M_PI * 180;
	 [object rotateByAxis:axis angle:angle];*/

	dragging = location;
	return YES;
}

@end
