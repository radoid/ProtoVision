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

	Color2D _color;
	CVDisplayLinkRef _displayLink;
	BOOL _initialized, _started;
	CGRect _backingFrame;
	double _last_time;
}
@synthesize backingFrame=_backingFrame, color=_color;


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
	return _backingFrame.size.width/self.frame.size.width;
}

- (void)setColor:(Color2D)newcolor	{
	_color = newcolor;
	glClearColor(_color.r, _color.g, _color.b, 1);
	self.needsDisplay = YES;
}


/**
 * Drawing
 */

- (void)prepareOpenGL {
	NSAssert(!_controller, nil);
	self.wantsBestResolutionOpenGLSurface = YES;
	_backingFrame = [self convertRectToBacking:[self frame]];
	glViewport(0, 0, _backingFrame.size.width, _backingFrame.size.height);

	glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
	glEnable(GL_MULTISAMPLE);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	self.color = Color2DMake(0.8, 0.8, 0.8, 1);

	_initialized = YES;
	if (_controller && !_started) {  // TODO remove?
		[_controller start];
		_started = YES;
	}
}

- (void)drawRect:(NSRect)rect {
    if (!_displayLink || CVDisplayLinkIsRunning(_displayLink))
		[self draw];
}

- (void)draw {
	if (_initialized) {
		CGLLockContext([self.openGLContext CGLContextObj]);
		[self.openGLContext makeCurrentContext];

		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		if (_started)
			[_controller draw];

		[self.openGLContext flushBuffer];

		CGLUnlockContext([self.openGLContext CGLContextObj]);
	}
}


/**
 * Reshaping
 */

- (void)reshape {
	if (_initialized) {
		CGLLockContext([self.openGLContext CGLContextObj]);
		[self.openGLContext makeCurrentContext];

		_backingFrame = [self convertRectToBacking:[self frame]];
		glViewport(0, 0, _backingFrame.size.width, _backingFrame.size.height);

		if (_started)
			[_controller reshape];

		[self.openGLContext update];

		CGLUnlockContext([self.openGLContext CGLContextObj]);
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
	@autoreleasepool {
		if (_controller && _started)
			[self updateAnimation];
	}
	return kCVReturnSuccess;
}

- (void)startAnimation {
	NSAssert(_initialized, nil);
	CGLLockContext([self.openGLContext CGLContextObj]);
	[self.openGLContext makeCurrentContext];

	if (!_started)
		[_controller start];
	else
		[_controller resume];  // TODO only if stopped
	_started = YES;
	_last_time = CACurrentMediaTime();

	CGLUnlockContext([self.openGLContext CGLContextObj]);

	GLint swapInt = 1;
	[[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
	CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
	CVDisplayLinkSetOutputCallback(_displayLink, &MyDisplayLinkCallback, (__bridge void *)self);
	CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, [[self openGLContext] CGLContextObj], [[self pixelFormat] CGLPixelFormatObj]);
	CVDisplayLinkStart(_displayLink);
}

- (void)stopAnimation {
	NSAssert(_initialized && _started, nil);
	CGLLockContext([self.openGLContext CGLContextObj]);
	[self.openGLContext makeCurrentContext];

	if (_displayLink) {
		CVDisplayLinkStop(_displayLink);
		CVDisplayLinkRelease(_displayLink);
		_displayLink = 0;
	}
	if (_started)
		[_controller stop];

	CGLUnlockContext([self.openGLContext CGLContextObj]);
}

- (void)updateAnimation {
	NSAssert(_initialized && _started, nil);
	CGLLockContext([self.openGLContext CGLContextObj]);
	[self.openGLContext makeCurrentContext];

	double time = CACurrentMediaTime(), delta = time - _last_time;
	_last_time = time;
	if ([_controller update:delta])
		//self.needsDisplay = YES;
		[self draw];

	CGLUnlockContext([self.openGLContext CGLContextObj]);
}

- (void)dealloc {
	if (_displayLink)
		[self stopAnimation];
}


/**
 * Keyboard events
 */

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)keyDown:(NSEvent *)event {
	NSAssert(_initialized && _started, nil);
	CGLLockContext([self.openGLContext CGLContextObj]);
	[self.openGLContext makeCurrentContext];

	if ([_controller keyDown:event.keyCode modifiers:(int)event.modifierFlags])
		self.needsDisplay = YES;

	CGLUnlockContext([self.openGLContext CGLContextObj]);
}

- (void)keyUp:(NSEvent *)event {
	NSAssert(_initialized && _started, nil);
	CGLLockContext([self.openGLContext CGLContextObj]);
	[self.openGLContext makeCurrentContext];

	if ([_controller keyUp:event.keyCode modifiers:(int)event.modifierFlags]
	 || [_controller keyPress:event.charactersIgnoringModifiers modifiers:(int)event.modifierFlags])
		self.needsDisplay = YES;

	CGLUnlockContext([self.openGLContext CGLContextObj]);
}


/**
 * Mouse events
 */

- (void)mouseDown:(NSEvent *)event {
	NSAssert(_initialized && _started, nil);
	CGLLockContext([self.openGLContext CGLContextObj]);
	[self.openGLContext makeCurrentContext];

	Vector2D location = Vector2DMake([NSEvent mouseLocation].x - _window.frame.origin.x, [NSEvent mouseLocation].y - _window.frame.origin.y);
	if ([_controller touchDown:location modifiers:(int)event.modifierFlags])
		self.needsDisplay = YES;

	CGLUnlockContext([self.openGLContext CGLContextObj]);
}

- (void)mouseDragged:(NSEvent *)event {
	NSAssert(_initialized && _started, nil);
	CGLLockContext([self.openGLContext CGLContextObj]);
	[self.openGLContext makeCurrentContext];

	Vector2D location = Vector2DMake([NSEvent mouseLocation].x - _window.frame.origin.x, [NSEvent mouseLocation].y - _window.frame.origin.y);
	if ([_controller touchMove:location modifiers:(int)event.modifierFlags])
		self.needsDisplay = YES;

	CGLUnlockContext([self.openGLContext CGLContextObj]);
}

- (void)mouseUp:(NSEvent *)event {
	NSAssert(_initialized && _started, nil);
	CGLLockContext([self.openGLContext CGLContextObj]);
	[self.openGLContext makeCurrentContext];

	Vector2D location = Vector2DMake([NSEvent mouseLocation].x - _window.frame.origin.x, [NSEvent mouseLocation].y - _window.frame.origin.y);
	if (_started && [_controller touchUp:location modifiers:(int)event.modifierFlags])
		self.needsDisplay = YES;

	CGLUnlockContext([self.openGLContext CGLContextObj]);
}


/**
 * Controller stack
 */

- (Controller3D *)controller {
	return _controller;
}

- (void)pushController:(Controller3D *)newcontroller {
	if (_controllerStack == nil)
		_controllerStack = [[NSMutableArray alloc] init];
	if (_controller)
		[_controller stop];
	[_controllerStack addObject:newcontroller];
	_controller = newcontroller;
	_controller.view = self;
	//_button = nil;  // TODO
	if (_initialized) {
		[_controller start];
		_started = YES;
		self.needsDisplay = YES;
	}
}

- (void)popWithObject:(id)result {
	NSAssert(_controller, @"Releasing empty controller stack!");
	if (_controllerStack /*&& [_controllerStack lastObject] == self*/) {  // TODO
		if ([_controllerStack count])
			[_controllerStack removeLastObject];
		_controller = [_controllerStack lastObject];
		//_button = nil;  // TODO
		if (_controller)
			[_controller resumeWithObject:result];
		else
			_controllerStack = nil;
		self.needsDisplay = YES;
	}
}

@end
