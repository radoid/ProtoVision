//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "TouchCubeController.h"


int main(int argc, char * argv[]) {
	return [[[TouchCubeController alloc] init] runAnimated];
}


@implementation TouchCubeController
{
	Camera3D *camera3d;
	Container3D *scene3d;
	Light3D *light;
	Vector2D dragging;
}

- (void)start {
	scene3d = [[Container3D alloc] init];
	camera3d = [[Camera3D alloc] initWithPerspectivePosition:Vector3DMake(-2, 2, -2) lookAt:Vector3DMake(0, 0.5, 0) up:Vector3DY fovy:60 aspect:_view.frame.size.width / _view.frame.size.height near:0.1f far:10];
	light = [[Light3D alloc] initWithDirection:Vector3DMake(5.0, -5.0, 15.0)];

	_view.color = Color2DFromHSL(.55, .3, .6, 1);

	Cube3D *box3d = [[Cube3D alloc] initWithWidth:1 height:1 depth:1];
	box3d.y = 0.1f;
	box3d.colorAmbient = Color2DFromHSL(.13, 1, 0.3, 1);
	box3d.colorDiffuse = Color2DFromHSL(.14, 1, 0.6, 1);
	box3d.colorSpecular= Color2DFromHSL(.14, 1, 0.9, 1);
	[scene3d add:box3d];

	Sphere3D *sphere3d = [[Sphere3D alloc] initWithRadius:1 levels:30];
	sphere3d.position = Vector3DMake(0.5f, 0.75f, 0.5f);
	sphere3d.colorAmbient = Color2DFromHSL(.08, 1, 0.3, 1);
	sphere3d.colorDiffuse = Color2DFromHSL(.10, 1, 0.6, 1);
	sphere3d.colorSpecular= Color2DFromHSL(.12, 1, 0.9, 1);
	[scene3d add:sphere3d];

	scene3d.program = [Program3D programNamed:@"specular"];
}

- (void)draw {
	[scene3d drawWithCamera:camera3d light:light];
}

- (BOOL)update {
	camera3d.position = Vector3DRotateByAxisAngle(camera3d.position, Vector3DY, 0.5f);
	[camera3d lookAt:Vector3DZero up:Vector3DY];
	return YES;
}

- (BOOL)touchDown:(Vector2D)location {
	dragging = location;
	return NO;
}

- (BOOL)touchMove:(Vector2D)location {
	float radius = 100;

	float angle = (location.x - dragging.x) / radius * 180/M_PI;
	[(Mesh3D *)[scene3d.children objectAtIndex:0] rotateByAxis:camera3d.up angle:angle];
	angle = - (location.y - dragging.y) / radius * 180/M_PI;
	[(Mesh3D *)[scene3d.children objectAtIndex:0] rotateByAxis:camera3d.right angle:angle];

	/*Vector3D movement = { location.x - dragging.x, location.y - dragging.y, 0 };
	Vector3D axis = Vector3DRotateWithAxisAngle(camera3d.up, camera3d.forward, - atan2f(movement.y, movement.x) * 180/M_PI);
	float angle = Vector3DLength(movement) / radius / M_PI * 180;
	[(Mesh3D *)[scene3d.children objectAtIndex:0] rotateByAxis:axis angle:angle];*/

	dragging = location;
	return YES;
}

@end
