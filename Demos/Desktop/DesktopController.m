#import "DesktopController.h"
#import <RadEngine/RadEngine.h>
#import <stdio.h>


@implementation DesktopController

- (void)showFile:(int)newfile {
	file = max(0, min(newfile, (int)files.count-1));
	NSString *filename = [files objectAtIndex:file];
	((NSView *)view).window.title = [NSString stringWithFormat:@"%d/%d %@", file, files.count, filename];

	if (model)
		[scene remove:model];
	model = nil;
	if ([filename hasSuffix:@".obj"])
		//model = [[[Object3D alloc] initWithOBJ:[[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension] ofType:[filename pathExtension]] size:4 rotation:Quaternion3DZero] autorelease];
		model = [[[Object3D alloc] initWithOBJ:[NSString stringWithFormat:@"%@/%@", folder, filename] size:3 rotation:Quaternion3DZero] autorelease];
	if (model)
		[scene add:model];
}

- (void)showFolder:(NSString *)newfolder {
	[folder release];
	folder = [newfolder retain]; // retain?
	[files release];
	files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder error:nil];
	files = [[files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.obj'"]] retain]; // retain?
	[scroller setCount:files.count];
}

- (id)initWithScroller:(id)initscroller {
	if ((self = [super init])) {
		scroller = initscroller;
	}
	return self;
}

- (void)start {
	NSLog(@"[DesktopController start]");
	if (!scene) {
		scene = [[Container3D alloc] init];
		camera = [[Camera3D alloc] initWithFrame:view.frame scale:view.scale position:Vector3DMake(0, 0, 3) center:Vector3DZero up:Vector3DY fovy:65 near:0.1f far:20.f];
		light0 = [[Light3D alloc] initWithDirection:Vector3DMake(-1, 0, 0) ambient:(GLfloat[]){0.1f, 0.1f, 0.2f, 1} diffuse:(GLfloat[]){1, 1, 0.8f, 1}];
		[camera setup];
		[light0 enableAt:0];
		
		//Box3D *box = [[[Box3D alloc] initWithWidth:1 height:1 depth:1] autorelease];
		//[scene add:box];
		
		//[self showFolder:[[NSBundle mainBundle] bundlePath]];
		[self showFolder:@"/Volumes/Ante/Modeli3D"];
		//[self showFolder:@"/Users/ante/Documents"];
		[self showFile:0];
	}

	glEnableClientState(GL_NORMAL_ARRAY);
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
}

- (void)reshape {
	if (camera)
		camera.frame = view.frame;
	view.repainting = YES;
}

- (void)update {
	camera.position = Vector3DRotateByAxisAngle(camera.position, Vector3DY, 5);
	[camera lookAt:Vector3DZero up:Vector3DY];
	view.repainting = YES;
}

- (void)touchBeganAtLocation:(Vector2D)location {
	dragging = location;
}

- (void)touchMovedAtLocation:(Vector2D)location {
	float radius = view.frame.size.height/6;
	
	float angle = (location.x - dragging.x) / radius * 180/M_PI;
	[(Object3D *)[scene.children objectAtIndex:0] rotateByAxis:camera.up angle:angle];
	angle = - (location.y - dragging.y) / radius * 180/M_PI;
	[(Object3D *)[scene.children objectAtIndex:0] rotateByAxis:camera.right angle:angle];
	
	/*Vector3D movement = { location.x - dragging.x, location.y - dragging.y, 0 };
	 Vector3D axis = Vector3DRotateWithAxisAngle(camera3d.up, camera3d.forward, - atan2f(movement.y, movement.x) * 180/M_PI);
	 float angle = Vector3DLength(movement) / radius / M_PI * 180;
	 [(Object3D *)[scene3d.children objectAtIndex:0] rotateByAxis:axis angle:angle];*/
	
	view.repainting = YES;
	dragging = location;
}

- (void)keyUp:(int)keyCode {
	if (keyCode == 53)  // Escape
		[NSApp terminate:self];
	else if (keyCode == 115)  // Home
		[scroller setIndex:0];
	else if (keyCode == 119)  // End
		[scroller setIndex:99999999];
	else if (keyCode == 116 || keyCode == 123 || keyCode == 126)  // PgUp ili Left ili Up
		[scroller setIndex:file-1];
	else if (keyCode == 121 || keyCode == 124 || keyCode == 125)  // PgDn ili Right ili Down
		[scroller setIndex:file+1];
}

- (void)draw {
	if (scene) {
		[camera setup];
		[light0 setup];
		[scene drawWithCamera:camera];
	}
}

- (void)dealloc {
	[camera release];
	[light0 release];
	[scene release];
	[super dealloc];
}
@end
