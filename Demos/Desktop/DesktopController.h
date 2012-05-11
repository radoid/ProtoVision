#import <RadEngine/RadEngine.h>


@interface DesktopController : Controller3D
{
	Container3D *scene;
	Camera3D *camera;
	Light3D *light0;
	Vector2D dragging;
	Object3D *model;

	NSString *folder;
	NSArray *files;
	int file;
	id scroller;
}

- (id)initWithScroller:(id)initscroller;
- (void)showFile:(int)newfile;
- (void)showFolder:(NSString *)newfolder;

@end
