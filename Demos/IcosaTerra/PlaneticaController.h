#import <RadEngine/RadEngine.h>
#import "IcosaTerra3D.h"
#import "SettingsController.h"


@interface PlaneticaController : Controller2D
{
	Container3D *scene3d;
	Camera3D *camera3d;
	IcosaTerra3D *terra;
	Container3D *player;
	Object3D *airplane;
	Light3D *light0, *light1;

	Box2D *background;
	Button2D *pause;
	
	Vector2D dragging;
	float dragging_angle;
	
	Gyro3D *gyro;

	BOOL pausing, gyroing, modeRotatingCamera;
	SettingsController *settings;
}
@end
