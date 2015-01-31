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
@property (nonatomic) Color2D ambient, diffuse;

- (id)initWithPosition:(Vector3D)position;
- (id)initWithDirection:(Vector3D)direction;
- (id)initWithPosition:(Vector3D)position ambient:(Color2D)ambient diffuse:(Color2D)diffuse;
- (id)initWithDirection:(Vector3D)direction ambient:(Color2D)ambient diffuse:(Color2D)diffuse;

@end
