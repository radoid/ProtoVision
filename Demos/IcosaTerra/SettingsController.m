#import "SettingsController.h"

@implementation SettingsController

@synthesize switchRolling, switchGyro;

+ (BOOL)rolling {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"Rolling"];
}

+ (BOOL)gyro {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"Gyro"];
}

- (IBAction)changedSwitch:(UISwitch *)sender {
	//NSLog(@"Prekidac je sada na %d", sender.on);
	if (sender == switchRolling)
		[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"Rolling"];
	if (sender == switchGyro)
		[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"Gyro"];
}

- (id)init {
	self = [self initWithNibName:@"SettingsView" bundle:nil];
	return self;
}

/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [self initWithNibName:@"SettingsView" bundle:nil];
	return self;
}*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	switchRolling.on = [SettingsController rolling];
	switchGyro.on = (!TARGET_IPHONE_SIMULATOR && [SettingsController gyro]);
	switchGyro.enabled = !TARGET_IPHONE_SIMULATOR;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end