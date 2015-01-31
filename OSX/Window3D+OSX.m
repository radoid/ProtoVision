//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Window3D+OSX.h"


@implementation Window3D

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen {
	return [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag screen:screen];
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
	if ((self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag])) {
		_view = [[View3D alloc] initWithFrame:self.frame];
		_view.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
		self.contentView = _view;
		self.delegate = self;
	}
	return self;
}

- (id)initWithFullScreen {
	if ((self = [self initWithContentRect:[[NSScreen mainScreen] frame] styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES])) {
		[self setLevel:NSMainMenuWindowLevel+1];
		[self setOpaque:YES];
		[self setHidesOnDeactivate:YES];
		[self makeKeyAndOrderFront:self];
	}
	return self;
}

- (void)awakeFromNib {
	self.contentView = _view;
}

- (BOOL)canBecomeKeyWindow {
     return YES;
}

- (BOOL)canBecomeMainWindow {
     return YES;
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
