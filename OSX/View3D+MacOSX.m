//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "View3D+MacOSX.h"


@implementation View3D
{
	NSMutableArray *_controllerStack;
	Controller3D *_controller;

	CGRect frame;
	Color2D color;
	NSTimer *timer;
	//CVDisplayLinkRef displayLink;
	BOOL _initialized, _started, _redrawing;
}
@synthesize color;


+ (NSOpenGLPixelFormat *)defaultPixelFormat {
	return [[NSOpenGLPixelFormat alloc] initWithAttributes:(NSOpenGLPixelFormatAttribute[]) {
		NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
		NSOpenGLPFAColorSize    , 24                           ,
		NSOpenGLPFAAlphaSize    , 8                            ,
		NSOpenGLPFADepthSize,	32,
		NSOpenGLPFADoubleBuffer ,
		NSOpenGLPFAAccelerated  ,
		NSOpenGLPFANoRecovery   ,
		0
/*		//NSOpenGLPFAWindow,//NSOpenGLPFAFullScreen,
		//NSOpenGLPFADoubleBuffer,
		NSOpenGLPFAColorSize, 24,
		NSOpenGLPFAAlphaSize, 8,
		NSOpenGLPFADepthSize, 32,
		//NSOpenGLPFANoRecovery,
		//NSOpenGLPFAAccelerated,
		//NSOpenGLPFAStencilSize, 8,
		//NSOpenGLPFAAccumSize, 0,
		0*/}];
}

- (void)awakeFromNib {

}

- (id)initWithFrame:(NSRect)initframe {
	if ((self = [super initWithFrame:initframe])) {
		frame = NSRectToCGRect(initframe);
		color = Color2DMake(.8, .8, .8, 1);
		_initialized = NO;
		//[[self openGLContext] makeCurrentContext];
	}
	return self;
}

- (id)initWithCoder:(NSCoder*)coder {
	if ((self = [super initWithCoder:coder])) {
		frame = NSRectToCGRect(_frame);
		_initialized = NO;
		//[[self openGLContext] makeCurrentContext];
	}
	return self;
}

- (void)setFrame:(NSRect)rect {
	[super setFrame:rect];
	//self.needsDisplay = YES;
	[self update];
}

- (float)scale {
	return 1;
}

- (void)reshape {
	frame = NSRectToCGRect(_frame);
	glViewport(0, 0, frame.size.width, frame.size.height);
	_redrawing = YES;
	@synchronized (_controllerStack) {
		[_controller reshape];
	}
}


/**
 * Drawing
 */

- (void)drawRect:(NSRect)rect {
	if (!_initialized) {
		glViewport(0, 0, frame.size.width, frame.size.height);
		glClearColor(0.6f, 0.6f, 0.6f, 1);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glEnable(GL_DEPTH_TEST);
		glEnable(GL_CULL_FACE);
		//glEnable(GL_TEXTURE_2D);
		//glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND_SRC);
//		glEnableClientState(GL_VERTEX_ARRAY);
		//glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		_initialized = YES;
	}

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	[(Controller3D *)_controller draw];
	_redrawing = NO;

	//if ([self inLiveResize] && !fAnimate)
	//	glFlush ();
	//else
		[[self openGLContext] flushBuffer];
}

- (void)setColor:(Color2D)newcolor	{
	color = newcolor;
	glClearColor(color.r, color.g, color.b, 1);
	self.needsDisplay = YES;
}


/**
 * Controller stack
 */

- (Controller3D *)controller {
	@synchronized (_controllerStack) {
		return _controller;
	}
}

- (void)pushController:(Controller3D *)newcontroller {
	@synchronized (_controllerStack) {
		if (_controllerStack == nil)
			_controllerStack = [[NSMutableArray alloc] init];
		if (_controller)
			[_controller pause];
		[_controllerStack addObject:newcontroller];
		_controller = newcontroller;
		_controller.view = self;
		//_button = nil;  // TODO
		//if (_started) {
			[_controller start];
			_redrawing = YES;
			self.needsDisplay = YES;
		//}
	}
}

- (void)popWithObject:(id)result {
	@synchronized (_controllerStack) {
		if (_controllerStack /*&& [_controllerStack lastObject] == self*/) {  // TODO
			if ([_controllerStack count])
				[_controllerStack removeLastObject];
			_controller = [_controllerStack lastObject];
			//_button = nil;  // TODO
			if (_controller)
				[_controller resumeWithObject:result];
			else {
				NSLog(@"Releasanje praznog controller stacka");
				_controllerStack = nil;
			}
			_redrawing = YES;
		}
	}
}

/**
 * Animation
 */

- (void)startAnimation {
	//NSLog(@"[View3D start]");
	if (_initialized) {
		if (!_started)
			[(Controller3D *)_controller start];
		else
			[(Controller3D *)_controller resume];
		_started = _redrawing = YES;
	}
	if (!timer)
		timer = [NSTimer scheduledTimerWithTimeInterval:1/30.f target:self selector:@selector(loopAnimation) userInfo:nil repeats:YES];
}

- (void)stopAnimation {
	//NSLog(@"[View3D stop]");
	if (timer)
		[timer invalidate];
	timer = nil;
	if (_started)
		[(Controller3D *)_controller pause];
}

- (void)loopAnimation {
	if (_initialized) {
		//[[self openGLContext] makeCurrentContext];
		if (!_started) {  // TODO ili onemogućiti da se pokrene animacija dok nije inicijaliziran GL?
			[(Controller3D *)_controller start];
			_started = _redrawing = YES;
		} else
			_redrawing |= [(Controller3D *)_controller update];
		if (_redrawing)
			[self drawRect:_frame];
	}
}
/*
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
	[(View3D *)displayLinkContext loopAnimation];
	return kCVReturnSuccess;
}

- (void)start {
	NSLog(@"[View3D start]");
	[(Controller3D *)_controller start];
	repainting = YES;

	GLint swapInt = 1;
	[[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
	// Create a display link capable of being used with all active displays
	CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
	// Set the renderer output callback function
	CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, self);

	// Set the display link for the current renderer
	CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
	CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
	CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);
	CVDisplayLinkStart(displayLink);
}*/


/**
 * Keyboard events
 */

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)keyDown:(NSEvent *)event {
	_redrawing |= [(Controller3D *)_controller keyDown:event.keyCode];
	if (_redrawing)
		self.needsDisplay = YES;
}

- (void)keyUp:(NSEvent *)event {
	_redrawing |= [(Controller3D *)_controller keyUp:event.keyCode];
	if (_redrawing)
		self.needsDisplay = YES;
}


/**
 * Mouse events
 */

- (void)mouseDown:(NSEvent *)event {
	Vector2D location = Vector2DMake([NSEvent mouseLocation].x - _window.frame.origin.x, [NSEvent mouseLocation].y - _window.frame.origin.y);
	_redrawing |= [(Controller3D *) _controller touchDown:location];
	if (_redrawing && !timer)
		self.needsDisplay = YES;
}

- (void)mouseUp:(NSEvent *)event {
	Vector2D location = Vector2DMake([NSEvent mouseLocation].x - _window.frame.origin.x, [NSEvent mouseLocation].y - _window.frame.origin.y);
	_redrawing |= [(Controller3D *) _controller touchUp:location];
	if (_redrawing && !timer)
		self.needsDisplay = YES;
}

- (void)mouseDragged:(NSEvent *)event {
	Vector2D location = Vector2DMake([NSEvent mouseLocation].x - _window.frame.origin.x, [NSEvent mouseLocation].y - _window.frame.origin.y);
	_redrawing |= [(Controller3D *) _controller touchMove:location];
	if (_redrawing && !timer)
		self.needsDisplay = YES;
}


/**
 * Deallocating
 */

- (void)dealloc {
    //if (displayLink)
	//	CVDisplayLinkRelease(displayLink);
}

@end
