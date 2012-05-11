#import <RadEngine/RadEngine.h>


@interface N9AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	View3D *glView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

