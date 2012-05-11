#import "PlaneticaController.h"
#import "SettingsController.h"


static const int n = 8;
static const float radius = 1;

static const float speedMotorLinear = 10;
static const float speedMotorAngular = 2;


@interface PlaneticaController (Private)
- (void)startgame;
@end


@implementation PlaneticaController

- (void)start {
	if (!scene3d) {
		scene3d = [[Container3D alloc] init];
		camera3d = [[Camera3D alloc] initWithFrame:view.frame scale:view.scale position:Vector3DMake(2, 2, 2) center:Vector3DZero up:Vector3DY fovy:60 near:0.01f far:100];
		
		terra = [[IcosaTerra3D alloc] initWithRadius:radius height:radius/3 levels:20];
		terra.color = Color2DMake(0, 1, 0, 1);
		[scene3d add:terra];
		
		player = [[Container3D alloc] init];
		[scene3d add:player];
		//airplane = [[Box3D alloc] initWithWidth:radius/40 height:radius/40 depth:radius/40];
		airplane = [[Object3D alloc] initWithOBJ:[[NSBundle mainBundle] pathForResource:@"f16" ofType:@"obj"] size:radius/8 rotation:Quaternion3DZero];
		//airplane.color = Color2DMake(1, 0, 0, 1);
		[player add:airplane];
		
		Sphere3D *sea = [[[Sphere3D alloc] initWithRadius:radius levels:20] autorelease];
		sea.color = Color2DMake(0.025f, 0.2f, 0.5f, 0.6f);
		[scene3d add:sea];

		light0 = [[Light3D alloc] initWithDirection:Vector3DMake(1, 0, 0) ambient:(float[]){0.f, 0.f, 0.f, 1.0f} diffuse:(float[]){.9f, .9f, .9f, 1.0f}];
		light1 = [[Light3D alloc] initWithDirection:Vector3DMake(-1, 0, 0) ambient:(float[]){0.f, 0.f, 0.f, 1.0f} diffuse:(float[]){.3f, .3f, .3f, 1.0f}];

		stage = [[Container2D alloc] init];  // release
		camera = [[Camera2D alloc] initWithFrame:view.frame coords:view.frame near:-1 far:1]; // release
		background = [[Box2D alloc] initWithWidth:480 height:320];
		background.opacity = 0;
		pause = [[Button2D alloc] initWithImageNamed:@"pause" hoverImageNamed:@"pausehover"];
		pause.origin = CGPointMake((int)(pause.width/2), (int)(pause.height/2));
		pause.position = Vector2DMake(view.frame.size.height - (int)(pause.width*2/3), (int)(pause.height*2/3));
		[stage add:background];
		[stage add:pause];

		camera3d.orientation = +90;
		camera.orientation = +90;

		[light0 enableAt:0];
		[light1 enableAt:1];

		[self startgame];
	}
	
	if (!gyro)
		gyro = [[Gyro3D alloc] initWithInterval:1/30.f];
	
	gyroing = ([SettingsController gyro] && !TARGET_IPHONE_SIMULATOR);
	modeRotatingCamera = [SettingsController rolling];
	
	glClearColor (.8f, .9f, 1, 1);
	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);
	glEnable(GL_BLEND);
	//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	//glShadeModel(GL_FLAT);//GL_SMOOTH);
	glEnable(GL_CULL_FACE);
	
	GLenum err = glGetError(); if (err) NSLog(@"[Controller start] GL ERROR %x", err);
}

- (void)stop {
	[gyro release];
	gyro = nil;
}

- (void)startgame {
	//eating = 0;
	Vector3D position = Vector3DRandom ();
	//for (int i=0; i < 1000 && terra.getHeight (position) > 0; i++)
	//	position = Vector3D.random ();
	[player setPosition:Vector3DScale(Vector3DUnit(position), radius * 1.05f)];
	[player directTo:Vector3DCross(player.position, Vector3DRandom()) up:player.position];
	[camera3d setPosition:Vector3DAdd(Vector3DAdd(player.position, Vector3DScale(player.forward, -radius / 2.5f)), Vector3DScale(player.up, radius/2.8f))];
	[camera3d lookAt:player.position up:player.up];
}

static CFTimeInterval lastTime;
static Vector3D stableGravity;
static float stableFactor = 0.8f;

- (void)update {
	CFTimeInterval time = CFAbsoluteTimeGetCurrent();
	float dt = (lastTime > 0 ? time - lastTime : 0);
	lastTime = time;
	
	if (pausing)
		return;

	// Accelerometer/ziroskop
	if (gyroing) {
		Vector3D gravity = Vector3DRotateByAxisAngle([gyro gravity], Vector3DZ, camera3d.orientation);
		stableFactor = (gyro.accurate ? 0.1f : 0.8f);
		gravity = stableGravity = Vector3DAdd(Vector3DScale(stableGravity, stableFactor), Vector3DScale(gravity, 1 - stableFactor));
		if (gravity.y < 0)
			dragging_angle = max(-60, min (+60, atan2f(gravity.x, -gravity.y) * 180/M_PI));// gravity.x * 90;
		else
			dragging_angle = (fabs(dragging_angle) > 5 ? dragging_angle/1.5f : 0);
		//[airplane setRotation:(modeRotatingCamera ? Quaternion3DZero : Quaternion3DMakeWithAxisAngle(Vector3DZFlip, dragging_angle))];
	}
	
	// Ispravljanje nagiba
	if (!gyroing && !dragging.x && !dragging.y && dragging_angle != 0) {
		dragging_angle = (fabs (dragging_angle) > 5 ? dragging_angle/1.5f : 0);
		//airplane.rotation = Quaternion3DMakeWithAxisAngle(Vector3DZFlip, dragging_angle);
	}
	//airplane.rotation = (modeRotatingCamera ? Quaternion3DMakeWithAxisAngle(Vector3DZFlip, dragging_angle) : Quaternion3DZero);
	airplane.rotation = Quaternion3DMakeWithAxisAngle(Vector3DZFlip, (modeRotatingCamera ? 0 : dragging_angle));

	Quaternion3D q = Quaternion3DMakeWithAxisAngle(player.right, -speedMotorLinear * dt);
	if (dragging_angle != 0)
		q = Quaternion3DRotateByAxisAngle(q, player.up, - dragging_angle * speedMotorAngular * dt);
	[player rotateAround:Vector3DZero rotation:q];
	[camera3d rotateAround:Vector3DZero rotation:q];
	if (modeRotatingCamera)
		[camera3d directTo:camera3d.forward up:Vector3DRotateByAxisAngle(camera3d.position, camera3d.forward, dragging_angle)];
	
	view.repainting = YES;
}

- (void)pause {
	pausing = !pausing;
	if (pausing) {
		[self stop];
		
		if (!settings)
			settings = [[SettingsController alloc] init];
		[(UIView *)view addSubview:settings.view];
	} else {
		if (settings)
			[settings.view removeFromSuperview];
		[settings release];
		settings = nil;

		modeRotatingCamera = [SettingsController rolling];
		gyroing = [SettingsController gyro];
		[self start];
	}
	background.opacity = (pausing ? 1 : 0);
}

- (void)buttonPressed:(id)button {
	if (button == pause)
		[self pause];
}

- (void)touchBeganAtLocation:(Vector2D)location {
	[super touchBeganAtLocation:location];
	
	dragging = location;
}

- (void)touchMovedAtLocation:(Vector2D)location {
	[super touchMovedAtLocation:location];
	
	if (!gyroing) {
		float dragging_radius = view.frame.size.height/6;
		dragging_angle = max (-60, min (+60, dragging_angle - (float) ((location.y - dragging.y) / dragging_radius * 180 / M_PI)));		
		view.repainting = YES;
	}
	dragging = location;
}

- (void)touchEndedAtLocation:(Vector2D)location {
	[super touchEndedAtLocation:location];
	
	dragging.x = dragging.y = 0;
}

- (void)draw {
	[Texture2D unbind];
	//glDisable(GL_TEXTURE_2D);
	//glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
	glEnable(GL_LIGHTING);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	[camera3d setup];
	[light0 setup];
	[light1 setup];
	[scene3d drawWithCamera:camera3d];
	
	//glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
	glDisable(GL_LIGHTING);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

	//[super draw];
	[camera setup];
	[stage drawWithCamera:camera];
	
	GLenum err = glGetError(); if (err) NSLog(@"[IcosaTerraController draw] GL ERROR %x", err);
}

- (void)dealloc {
	[scene3d release];
	[camera3d release];
	[terra release];
	[player release];
	[airplane release];
	[light0 release];
	[light1 release];

	[stage release];
	[camera release];
	[pause release];
	[background release];

	[gyro release];
	[settings release];

	[super dealloc];
}

@end
