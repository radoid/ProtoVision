#import "RotatingBoxController.h"


@implementation RotatingBoxController

- (void)start {
	if (!scene3d) {
		scene3d = [[Container3D alloc] init];
		camera3d = [[Camera3D alloc] initWithFrame:view.frame scale:view.scale position:Vector3DMake(2, 2, 2) center:Vector3DZero up:Vector3DY fovy:60 near:0.1f far:10];

		Box3D *box3d = [[[Box3D alloc] initWithWidth:1 height:1 depth:1] autorelease];
		box3d.y = 0.1f;
		box3d.color = Color2DMake(1, 0.1, 0.1, 1);
		[scene3d.children addObject:box3d];
		
		Sphere3D *sphere3d = [[[Sphere3D alloc] initWithRadius:1 levels:10] autorelease];
		sphere3d.position = Vector3DMake(0.5f, 0.5f, 0.5f);
		sphere3d.color = Color2DMake(0.1, 1, 0.1, 1);
		[scene3d.children addObject:sphere3d];
		
		light0 = [[Light3D alloc] initWithDirection:Vector3DMake(5.0, 5.0, 15.0) ambient:(GLfloat[]) {0.2, 0.2, 0.2} diffuse:(GLfloat[]) {0.6, 0.6, 0.6}];
		light1 = [[Light3D alloc] initWithDirection:Vector3DMake(-5.0, -5.0, 15.0) ambient:(GLfloat[]) {0.2, 0.2, 0.2} diffuse:(GLfloat[]) {0.6, 0.6, 0.6}];
		[light0 enableAt:0];
		//[light1 enableAt:1];

		glEnable(GL_DEPTH_TEST);
		glEnableClientState(GL_NORMAL_ARRAY);
	}
}

- (void)draw {
	[camera3d setup];
	//[light0 setup];
	//[light1 setup];
	[scene3d drawWithCamera:camera3d];  // TODO: ili običnu metodu draw?
}

- (void)update {
	//[(Object3D *)[scene3d.children objectAtIndex:0] rotateByAxis:Vector3DZ angle:10];
	camera3d.position = Vector3DRotateByAxisAngle(camera3d.position, Vector3DY, 0.5f);
	[camera3d lookAt:Vector3DZero up:Vector3DY];
	view.repainting = YES;
}

- (void)touchBeganAtLocation:(Vector2D)location {
	[super touchBeganAtLocation:location];
	
	dragging = location;
}

- (void)touchMovedAtLocation:(Vector2D)location {
	[super touchMovedAtLocation:location];
	
	float radius = 200;
	
	float angle = (location.x - dragging.x) / radius * 180/M_PI;
	[(Object3D *)[scene3d.children objectAtIndex:0] rotateByAxis:camera3d.up angle:angle];
	angle = - (location.y - dragging.y) / radius * 180/M_PI;
	[(Object3D *)[scene3d.children objectAtIndex:0] rotateByAxis:camera3d.right angle:angle];

	/*Vector3D movement = { location.x - dragging.x, location.y - dragging.y, 0 };
	Vector3D axis = Vector3DRotateWithAxisAngle(camera3d.up, camera3d.forward, - atan2f(movement.y, movement.x) * 180/M_PI);
	float angle = Vector3DLength(movement) / radius / M_PI * 180;
	[(Object3D *)[scene3d.children objectAtIndex:0] rotateByAxis:axis angle:angle];*/

	view.repainting = YES;
	dragging = location;
}

- (void)dealloc {
	[scene3d release];
	[camera3d release];
	[light0 release];
	[light1 release];
	[super dealloc];
}
	
@end
