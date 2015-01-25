//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


@interface Container2D : Object2D <NSCopying>
{
//	@private
	NSMutableArray *children;
}
@property (nonatomic, readonly) NSMutableArray *children;

- (void)add:(Object2D *)child;
- (void)remove:(Object2D *)child;
- (void)removeAll;

- (id)findButtonAtLocation:(Vector2D)location;

- (void)drawWithCamera:(Camera2D *)camera;

@end
