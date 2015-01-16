//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


@interface Window3D : NSWindow <NSWindowDelegate>

@property (nonatomic, readonly) View3D *view;

- (void)pushController:(Controller3D *)controller;

@end
