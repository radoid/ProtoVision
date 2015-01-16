//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


@interface Object3D (OBJ)

- (id)initWithOBJ:(NSString *)path;
- (id)initWithOBJ:(NSString *)path size:(float)size rotation:(Quaternion3D)correction;

@end
