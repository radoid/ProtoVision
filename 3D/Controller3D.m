//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Controller3D.h"


@interface Controller3D (P)

- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;
- (void)draw;

#if TARGET_OS_IPHONE
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)orientationDidChange:(NSNotification *)note;
#endif

@end


@implementation Controller3D

- (void)start {}
- (void)stop {}
- (void)pause {}
- (void)resume {}
- (void)resumeWithObject:(id)result {}
- (BOOL)update {return NO;}

- (BOOL)touchDown:(Vector2D)location {return NO;}
- (BOOL)touchMove:(Vector2D)location {return NO;}
- (BOOL)touchUp:(Vector2D)location {return NO;}

#if TARGET_OS_IPHONE
#else
- (BOOL)keyDown:(int)keyCode {
	if (keyCode == 53)  // Escape
		[NSApp terminate:self];
	return NO;
}
- (BOOL)keyUp:(int)keyCode {return NO;}
#endif

- (void)reshape {}

- (void)draw {}

- (void)pushController:(Controller3D *)controller {
	[_view pushController:controller];
}
- (void)popWithObject:(NSObject *)result {
	[_view popWithObject:result];
}

@end
