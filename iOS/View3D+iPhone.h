//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"

@class Controller3D;


@interface View3D : UIView

@property (nonatomic) Color2D color;

- (id)initWithFrame:(CGRect)rect;
- (id)initWithFrame:(CGRect)rect useHighResolution:(BOOL)useRetina useDepthBuffer:(BOOL)useDepthBuffer;
- (id)initWithCoder:(NSCoder*)coder;

- (float)scale;

- (void)pushController:(Controller3D *)controller;
- (void)popWithObject:(id)result;
- (Controller3D *)controller;

- (void)startAnimation;
- (void)stopAnimation;

@end
