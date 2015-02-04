//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


@interface Light3D : NSObject

@property (nonatomic) BOOL hasPosition, hasDirection;
@property (nonatomic) Vector3D position, direction;
@property (nonatomic) Color2D color;

- (id)initWithPosition:(Vector3D)position;
- (id)initWithDirection:(Vector3D)direction;
- (id)initWithPosition:(Vector3D)position color:(Color2D)ambient;
- (id)initWithDirection:(Vector3D)direction color:(Color2D)ambient;

@end
