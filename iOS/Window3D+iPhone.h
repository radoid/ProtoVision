//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import <UIKit/UIKit.h>
#import "ProtoVision.h"


@interface Window3D : UIWindow

@property (nonatomic, readonly) View3D *view;

- (id)initWithController:(Controller3D *)controller;

- (void)pushController:(Controller3D *)controller;

@end
