#import <UIKit/UIKit.h>

@interface SettingsController : UIViewController
{
	UISwitch *switchRolling, *switchGyro;
}
@property (nonatomic, retain) IBOutlet UISwitch *switchRolling, *switchGyro;

- (IBAction)changedSwitch:(UISwitch *)sender;

+ (BOOL)rolling;
+ (BOOL)gyro;

@end
