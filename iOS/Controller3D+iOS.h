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

- (BOOL)touchDown:(Vector2D)location;
- (BOOL)touchMove:(Vector2D)location;
- (BOOL)touchUp:(Vector2D)location;

- (void)reshape;
- (void)draw;

- (void)pushController:(Controller3D *)controller;
- (void)popWithObject:(NSObject *)result;

- (int)run;

@end
