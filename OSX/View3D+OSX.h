//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import <Cocoa/Cocoa.h>
#import "ProtoVision.h"

@class Controller3D;


@interface View3D : NSOpenGLView

@property (nonatomic, readonly) CGRect backingFrame;
@property (nonatomic) Color2D color;

- (float)scale;

- (void)pushController:(Controller3D *)controller;
- (void)popWithObject:(id)result;
- (Controller3D *)controller;

- (void)startAnimation;
- (void)stopAnimation;

@end
