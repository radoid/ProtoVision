//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "View3D+OSX.h"


@implementation View3D
{
	NSMutableArray *_controllerStack;
	Controller3D *_controller;

	Color2D color;
	CVDisplayLinkRef displayLink;
	BOOL _started, _redrawing;
	CGRect backingFrame;
}
@synthesize backingFrame, color;


- (id)initWithFrame:(NSRect)initframe {
	NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:(NSOpenGLPixelFormatAttribute[]) {
		NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
		NSOpenGLPFAColorSize, 24,
		NSOpenGLPFAAlphaSize, 8,
		NSOpenGLPFADepthSize, 32,
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFAAccelerated,
		NSOpenGLPFANoRecovery,
		NSOpenGLPFASampleBuffers, 1,
		NSOpenGLPFASamples, 2,
		//NSOpenGLPFAStencilSize, 8,
		//NSOpenGLPFAAccumSize, 0,
		0}];
	return [super initWithFrame:initframe pixelFormat:format];
}

- (id)initWithCoder:(NSCoder*)coder {
	if ((self = [super initWithCoder:coder])) {
		return [self initWithFrame:_frame];
	}
	return self;
}

- (void)awakeFromNib {
	[self initWithFrame:self.frame];
}

- (void)setFrame:(NSRect)rect {
	[super setFrame:rect];
	[self update];
}

- (float)scale {
	return 1;
}

- (void)reshape {
	backingFrame = [self convertRectToBacking:[self frame]];
	glViewport(0, 0, backingFrame.size.width, backingFrame.size.height);
	_redrawing = YES;
	@synchronized (_controllerStack) {
		[_controller reshape];
	}
}


/**
 * Drawing
 */

- (void)prepareOpenGL {
	self.wantsBestResolutionOpenGLSurface = YES;
	backingFrame = [self convertRectToBacking:[self frame]];
	glViewport(0, 0, backingFrame.size.width, backingFrame.size.height);

	glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
	glEnable(GL_MULTISAMPLE);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	self.color = Color2DMake(0.8, 0.8, 0.8, 1);
}

- (void)drawRect:(NSRect)rect {
	if (!displayLink) {
		[self.openGLContext makeCurrentContext];
		[self draw];
	}
}

- (void)draw {
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	[(Controller3D *)_controller draw];
	_redrawing = NO;

	[self.openGLContext flushBuffer];
}

- (void)setColor:(Color2D)newcolor	{
	color = newcolor;
	glClearColor(color.r, color.g, color.b, 1);
	self.needsDisplay = _redrawing = YES;
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
		[_controller start];
		_started = _redrawing = YES;
		self.needsDisplay = YES;
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
				NSLog(@"Releasing empty controller stack!");
				_controllerStack = nil;
			}
			_redrawing = YES;
		}
	}
}

/**
 * Animation
 */

static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext) {
	CVReturn result = [(__bridge View3D *)displayLinkContext getFrameForTime:outputTime];
	return result;
}

- (CVReturn)getFrameForTime:(const CVTimeStamp*)outputTime {
	if (_redrawing) {
		[self.openGLContext makeCurrentContext];
		[self draw];
	}
	return kCVReturnSuccess;
}

- (void)startAnimation {
	if (!_started)
		[_controller start];
	else
		[_controller resume];
	_started = _redrawing = YES;

	GLint swapInt = 1;
	[[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
	CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
	CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, (__bridge void *)self);
	CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
	CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
	CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);
	CVDisplayLinkStart(displayLink);
}

- (void)stopAnimation {
	if (displayLink)
		CVDisplayLinkRelease(displayLink);
	displayLink = 0;
	if (_started)
		[(Controller3D *)_controller pause];
}

- (void)updateAnimation {
	//[[self openGLContext] makeCurrentContext];
	if (!_started) {
		[(Controller3D *)_controller start];
		_started = _redrawing = YES;
	} else
		_redrawing |= [(Controller3D *)_controller update];
	if (_redrawing && !displayLink)
		[self drawRect:_frame];
}


/**
 * Keyboard events
 */

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)keyDown:(NSEvent *)event {
	_redrawing |= [(Controller3D *)_controller keyDown:event.keyCode modifiers:event.modifierFlags];
	if (_redrawing)
		self.needsDisplay = YES;
}

- (void)keyUp:(NSEvent *)event {
	_redrawing |= [(Controller3D *)_controller keyUp:event.keyCode modifiers:event.modifierFlags];
	if (_redrawing)
		self.needsDisplay = YES;
}

- (void)keyPress:(NSEvent *)event {
	_redrawing |= [(Controller3D *)_controller keyPress:event.charactersIgnoringModifiers modifiers:event.modifierFlags];
	if (_redrawing)
		self.needsDisplay = YES;
}


/**
 * Mouse events
 */

- (void)mouseDown:(NSEvent *)event {
	Vector2D location = Vector2DMake([NSEvent mouseLocation].x - _window.frame.origin.x, [NSEvent mouseLocation].y - _window.frame.origin.y);
	_redrawing |= [(Controller3D *) _controller touchDown:location modifiers:event.modifierFlags];
	if (_redrawing && !displayLink)
		self.needsDisplay = YES;
}

- (void)mouseUp:(NSEvent *)event {
	Vector2D location = Vector2DMake([NSEvent mouseLocation].x - _window.frame.origin.x, [NSEvent mouseLocation].y - _window.frame.origin.y);
	_redrawing |= [(Controller3D *) _controller touchUp:location modifiers:event.modifierFlags];
	if (_redrawing && !displayLink)
		self.needsDisplay = YES;
}

- (void)mouseDragged:(NSEvent *)event {
	Vector2D location = Vector2DMake([NSEvent mouseLocation].x - _window.frame.origin.x, [NSEvent mouseLocation].y - _window.frame.origin.y);
	_redrawing |= [(Controller3D *) _controller touchMove:location modifiers:event.modifierFlags];
	if (_redrawing && !displayLink)
		self.needsDisplay = YES;
}

@end
