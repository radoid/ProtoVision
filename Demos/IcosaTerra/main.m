#import "IcosaTerraAppDelegate.h"

int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([IcosaTerraAppDelegate class]));
    [pool release];
    return retVal;
}
