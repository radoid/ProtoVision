//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "SpinningCubeController.h"


@implementation SpinningCubeController
{
	Container3D *scene;
	Camera3D *camera;
	Vector3D light;
	Vector2D dragging;
	Object3D *model;
}

- (void)start {
	scene = [[Container3D alloc] init];
	camera = [[Camera3D alloc] initWithPosition:Vector3DMake(2, 1, 1) lookAt:Vector3DZero up:Vector3DY fovy:65 aspect:_view.frame.size.width/_view.frame.size.height near:0.1f far:20.f];
	light = Vector3DMake(-1, -0.25, 0);

	Box3D *box = [[Box3D alloc] initWithWidth:1 height:1 depth:1];
	[scene add:box];
}

- (void)draw {
	[scene drawWithCamera:camera light:light];
}

- (BOOL)update {
	camera.position = Vector3DRotateByAxisAngle(camera.position, Vector3DY, 5);
	[camera lookAt:Vector3DZero up:Vector3DY];
	return YES;
}

- (void)reshape {
	camera.aspect = _view.frame.size.width/_view.frame.size.height;
}

- (BOOL)touchDown:(Vector2D)location modifiers:(int)flags {
	dragging = location;
	return NO;
}

- (BOOL)touchMove:(Vector2D)location modifiers:(int)flags {
	float radius = _view.frame.size.height/5;

	float angle = (location.x - dragging.x) / radius * 180/M_PI;
	[(Object3D *)[scene.children objectAtIndex:0] rotateByAxis:camera.up angle:angle];
	angle = - (location.y - dragging.y) / radius * 180/M_PI;
	[(Object3D *)[scene.children objectAtIndex:0] rotateByAxis:camera.right angle:angle];

	/*Vector3D movement = { location.x - dragging.x, location.y - dragging.y, 0 };
	 Vector3D axis = Vector3DRotateWithAxisAngle(camera3d.up, camera3d.forward, - atan2f(movement.y, movement.x) * 180/M_PI);
	 float angle = Vector3DLength(movement) / radius / M_PI * 180;
	 [(Object3D *)[scene3d.children objectAtIndex:0] rotateByAxis:axis angle:angle];*/

	dragging = location;
	return YES;
}

@end
