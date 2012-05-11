#import "AppDelegate.h"
#import "DesktopController.h"


@implementation AppDelegate

@synthesize window=_window, view=_view, scrollview=_scrollview;

- (void)setCount:(int)count {
	scrollcount = max(1, count);
	scrollindex = max(0, min(scrollindex, scrollcount-1));
	// vidljivi dio i ukupna duljina
	clip = _scrollview.contentView.bounds.size;
	full = NSMakeSize(clip.width, clip.height * scrollcount);
	// veličine viewova
	[_view setFrame:NSMakeRect(0, 0, clip.width, clip.height)];
	[_scrollview.documentView setFrame:NSMakeRect(0, 0, full.width, full.height)];
	// brzine scrollera
	[_scrollview setVerticalPageScroll:0];
	[_scrollview setVerticalLineScroll:clip.height];
	// položaj scrollera
	[_scrollview.documentView scrollPoint:NSMakePoint(0, full.height - (scrollindex + 1) * clip.height)];
}

- (void)setIndex:(int)index {
	index = max(0, min(index, scrollcount-1));
	if (index != scrollindex) {
		NSLog(@"Scrolling to %d = %.0f / %.0f / %.0f", index, _scrollview.contentView.bounds.origin.y, clip.height, ((NSView *)_scrollview.documentView).frame.size.height);
		scrollindex = index;
		[_scrollview.documentView scrollPoint:NSMakePoint(0, full.height - (scrollindex + 1) * clip.height)];
		[(DesktopController *)_controller showFile:scrollindex];
	}
}

- (void)notifiedWindowDidResize:(NSNotification *)n {
	resizing = YES;
	self.count = scrollcount;
	resizing = NO;
}

- (void)notifiedViewBoundsDidChange:(NSNotification *)n {
	if (resizing || _scrollview.contentView.bounds.size.height != clip.height)  // da scroll ne preduhitri resize ili se uplete u nj
		return;
	int newindex = scrollcount-1 - round(_scrollview.contentView.bounds.origin.y / clip.height);
	//NSLog(@"Scrolling %d = %.0f / %.0f / %.0f", index, _scrollview.contentView.bounds.origin.y, clip.height, ((NSView *)_scrollview.documentView).frame.size.height);
	if (newindex != scrollindex) {
		if (newindex >= 0 && newindex < scrollcount) {
			self.index = newindex;
		} else
			NSLog(@"INVALID OFFSET %d!", newindex);
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	//[_window setFrameOrigin:CGPointMake(0,0)];
	//[_window setFrameTopLeftPoint:NSMakePoint(0, 0)];
	//[_window setFrame:NSMakeRect(20, 20, 500, 500) display:YES];
	[_window center];
	[_window zoom:self];

	_controller = [[DesktopController alloc] initWithScroller:self];
	[_view pushController:_controller];
	[_view start];
	
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(notifiedWindowDidResize:) name:NSWindowDidResizeNotification object:_window];
	
	_scrollview.scrollsDynamically = NO;
	_scrollview.contentView.postsBoundsChangedNotifications = YES;
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(notifiedViewBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:[_scrollview contentView]];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
	[_view stop];
	[_controller release];
	_controller = nil;
}

@end
