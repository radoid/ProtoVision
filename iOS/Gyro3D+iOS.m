//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Gyro3D+iOS.h"


@implementation Gyro3D

@synthesize kFilter;

- (id)initWithInterval:(float)interval {
	//if (TARGET_IPHONE_SIMULATOR || mm || accel)
	//	return nil;
	if ((self = [super init])) {
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4 && !TARGET_IPHONE_SIMULATOR) {
			mm = [[CMMotionManager alloc] init];
			if (mm && mm.deviceMotionAvailable) {
				mm.deviceMotionUpdateInterval = interval;
				[mm startDeviceMotionUpdates];
				NSLog(@"Ziroskop prisutan i pokrenut. :D");
			} else if (mm)
				mm = nil;
		}
		if (!mm) {
			if ((accel = [UIAccelerometer sharedAccelerometer])) {
				accel.delegate = self;
				accel.updateInterval = interval;
				NSLog(@"Akcelerometar prisutan i pokrenut. :)");
			} else
				NSLog(@"Nema ni ziroskopa ni akcelerometra?!");
		}
	}
	return self;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	_x = acceleration.x * (1-kFilter) + _x * kFilter;
	_y = acceleration.y * (1-kFilter) + _y * kFilter;
	_z = acceleration.z * (1-kFilter) + _z * kFilter;
}

- (BOOL)accurate {
	return (mm != nil);
}

- (Vector3D)gravity {
	if (!TARGET_IPHONE_SIMULATOR && mm && mm.deviceMotionAvailable) {
		CMDeviceMotion *dm = mm.deviceMotion;
		return Vector3DMake(dm.gravity.x, dm.gravity.y, dm.gravity.z);
	}
	else if (!TARGET_IPHONE_SIMULATOR && accel)
		return Vector3DMake(_x, _y, _z);
	else
		return Vector3DMake(0, -0.5, -0.5);
}

- (void)dealloc {
	if (mm)
		NSLog(@"Stopping gyroscope");
	if (accel)
		NSLog(@"Stopping accelerometer");
	[mm stopDeviceMotionUpdates];
	if (accel)
		accel.delegate = nil;
}

@end
