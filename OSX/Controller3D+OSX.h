//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


@interface Controller3D : NSObject <NSApplicationDelegate>
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

- (void)reshape;
- (void)draw;

- (void)pushController:(Controller3D *)controller;
- (void)popWithObject:(NSObject *)result;

- (int)run;

- (int)runAnimated;

- (BOOL)keyDown:(int)keyCode modifiers:(int)flags;
- (BOOL)keyUp:(int)keyCode modifiers:(int)flags;
- (BOOL)keyPress:(unichar)unicode modifiers:(int)flags;

- (BOOL)touchDown:(Vector2D)location modifiers:(int)flags;
- (BOOL)touchMove:(Vector2D)location modifiers:(int)flags;
- (BOOL)touchUp:(Vector2D)location modifiers:(int)flags;

@end