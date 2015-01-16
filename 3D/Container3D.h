//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


@interface Container3D : Object3D <NSCopying>
{
	NSMutableArray *children;
}
@property (nonatomic, readonly) NSMutableArray *children;

- (void)add:(Object3D *)child;
- (void)remove:(Object3D *)child;
- (void)removeAll;

@end
