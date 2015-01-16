//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "ProtoVision.h"


@interface Gyro3D : NSObject <UIAccelerometerDelegate>
{
	CMMotionManager *mm;
	UIAccelerometer *accel;
	UIAccelerationValue _x, _y, _z;
	float kFilter;
}
@property (nonatomic, readonly) BOOL accurate;
@property (nonatomic, readonly) Vector3D gravity;
@property (nonatomic) float kFilter;

- (id)initWithInterval:(float)interval;

@end
