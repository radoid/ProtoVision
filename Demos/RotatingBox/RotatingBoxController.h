#import <RadEngine/RadEngine.h>


@interface RotatingBoxController : Controller3D
{
	Camera3D *camera3d;
	Container3D *scene3d;
	Light3D *light0, *light1;
	Vector2D dragging;
}

- (void)start;

@end
