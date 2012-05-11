#import <Cocoa/Cocoa.h>
#import "View3D+MacOSX.h"
#import "Controller3D.h"


@interface AppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow *_window;
	View3D *_view;
	Controller3D *_controller;

	NSScrollView *_scrollview;
	int scrollcount, scrollindex;
	NSSize clip, full;
	bool resizing;
}
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSView *view;
@property (assign) IBOutlet NSScrollView *scrollview;

@end
