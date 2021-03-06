//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE

	#import <CoreGraphics/CoreGraphics.h>
	#import <OpenGLES/ES3/gl.h>

#else

	#import <OpenGL/OpenGL.h>
	#import <OpenGL/gl3.h>

#endif


#import "3D/Matrix4x4.h"
#import "2D/Vector2D.h"
#import "3D/Vector3D.h"
#import "2D/Color2D.h"

#import "2D/Texture2D.h"
#import "3D/FrameBuffer3D.h"

#import "3D/Program3D.h"

#import "3D/Buffer3D.h"
#import "2D/Buffer2D.h"

#import "3D/VectorIJK.h"
#import "3D/Plane3D.h"
#import "3D/Ray3D.h"
#import "3D/Quaternion3D.h"
#import "3D/Object3D.h"

#import "3D/Mesh3D.h"
#import "3D/Mesh3D+OBJ.h"
#import "3D/Container3D.h"
#import "3D/Cube3D.h"
#import "3D/Line3D.h"
#import "3D/Disc3D.h"
#import "3D/Sphere3D.h"
#import "3D/Pyramid3D.h"
#import "3D/Camera3D.h"
#import "3D/Light3D.h"

#import "2D/Object2D.h"
#import "2D/Mesh2D.h"
#import "2D/Camera2D.h"
#import "2D/Container2D.h"
#import "2D/Box2D.h"
#import "2D/Line2D.h"
#import "2D/Circle2D.h"
#import "2D/Polygon2D.h"
#import "2D/Font2D.h"
#import "2D/Text2D.h"

#import "2D/Image2D.h"
#import "2D/Button2D.h"

#if TARGET_OS_IPHONE
	#import "iOS/Gyro3D+iOS.h"
	#import "iOS/View3D+iOS.h"
	#import "iOS/Window3D+iOS.h"
	#import "iOS/Controller3D+iOS.h"
#else
	#import "OSX/View3D+OSX.h"
	#import "OSX/Window3D+OSX.h"
	#import "OSX/Controller3D+OSX.h"
#endif

#import "2D/Controller2D.h"


#ifndef min
	#define min(a, b)  ((a) < (b) ? (a) : (b))
#endif
#ifndef max
	#define max(a, b)  ((a) > (b) ? (a) : (b))
#endif
