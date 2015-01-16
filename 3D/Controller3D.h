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
}

@property (nonatomic) View3D *view;

- (void)start;
- (void)pause;
- (void)resume;
- (void)resumeWithObject:(id)result;
- (void)stop;
- (BOOL)update;

- (BOOL)touchDown:(Vector2D)location;
- (BOOL)touchMove:(Vector2D)location;
- (BOOL)touchUp:(Vector2D)location;

#if TARGET_OS_IPHONE
#else
- (BOOL)keyDown:(int)keyCode;
- (BOOL)keyUp:(int)keyCode;
#endif

- (void)reshape;
- (void)draw;

- (void)pushController:(Controller3D *)controller;
- (void)popWithObject:(NSObject *)result;

@end