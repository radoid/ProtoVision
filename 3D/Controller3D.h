//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


@interface Controller3D : NSObject
{
	View3D *_view;
	Window3D *_window;
}

@property (nonatomic) View3D *view;

- (void)start;
- (void)stop;
- (void)resume;
- (void)resumeWithObject:(id)result;
- (BOOL)update:(float)delta;

#if TARGET_OS_IPHONE
- (BOOL)touchDown:(Vector2D)location;
- (BOOL)touchMove:(Vector2D)location;
- (BOOL)touchUp:(Vector2D)location;
#else
- (BOOL)touchDown:(Vector2D)location modifiers:(int)flags;
- (BOOL)touchMove:(Vector2D)location modifiers:(int)flags;
- (BOOL)touchUp:(Vector2D)location modifiers:(int)flags;
#endif

#if TARGET_OS_IPHONE
#else
- (BOOL)keyDown:(int)keyCode modifiers:(int)flags;
- (BOOL)keyUp:(int)keyCode modifiers:(int)flags;
- (BOOL)keyPress:(NSString *)key modifiers:(int)flags;
#endif

- (void)reshape;
- (void)draw;

- (void)pushController:(Controller3D *)controller;
- (void)popWithObject:(NSObject *)result;

@end
