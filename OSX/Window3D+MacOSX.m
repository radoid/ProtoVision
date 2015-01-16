//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "Window3D+MacOSX.h"


@implementation Window3D

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
	if ((self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag])) {
		_view = [[View3D alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
		_view.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
		self.contentView = _view;
		self.delegate = self;
	}
	return self;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen {
	NSLog(@"initWithContentRect:screen:");
	if ((self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag screen:screen])) {
		_view = [[View3D alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
		_view.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
		self.contentView = _view;
		self.delegate = self;
	}
	return self;
}

- (void)awakeFromNib {
	self.contentView = _view;
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
	//NSLog(@"windowDidBecomeKey");
	//[_view startAnimation];
}

- (void)windowDidResignKey:(NSNotification *)notification {
	//NSLog(@"windowDidResignKey");
	//[_view stopAnimation];
}

- (void)pushController:(Controller3D *)controller {
	[_view pushController:controller];
}

@end
