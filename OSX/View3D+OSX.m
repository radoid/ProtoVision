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

	NSOpenGLContext *_openGLContext;
	NSOpenGLPixelFormat *_pixelFormat;

	Color2D _color;
	CVDisplayLinkRef _displayLink;
	BOOL _prepared, _started, _animated;
	CGRect _backingFrame;
	double _last_time;
}


- (id)initWithFrame:(NSRect)frameRect shareContext:(NSOpenGLContext*)context {
	_pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:(NSOpenGLPixelFormatAttribute[]) {
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
	NSAssert(_pixelFormat, @"View3D can't initialize OpenGL");
    _openGLContext = [[NSOpenGLContext alloc] initWithFormat:_pixelFormat shareContext:context];

	if (self = [super initWithFrame:frameRect]) {
		[_openGLContext makeCurrentContext];

		GLint swapInt = 1;
		[_openGLContext setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];

		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reshape) name:NSViewGlobalFrameDidChangeNotification object:self];
	}
	return self;
}

- (id)initWithFrame:(NSRect)initframe {
	return [self initWithFrame:initframe shareContext:nil];
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
/*
- (void)setFrame:(NSRect)rect {
	[super setFrame:rect];
	//[self update];
}*/

- (void)lockFocus {
	[super lockFocus];
	if (_openGLContext.view != self)
		_openGLContext.view = self;
}

- (float)scale {
	return _backingFrame.size.width/self.frame.size.width;
}

- (void)setColor:(Color2D)color	{
	_color = color;
	glClearColor(_color.r, _color.g, _color.b, 1);
	self.needsDisplay = YES;
}


/**
 * Reshaping
 */

- (void)reshape {
	//NSLog(@"reshape...");
	if (_prepared) {
		CGLLockContext([_openGLContext CGLContextObj]);
		[_openGLContext makeCurrentContext];

		_backingFrame = [self convertRectToBacking:[self frame]];
		glViewport(0, 0, _backingFrame.size.width, _backingFrame.size.height);

		if (_started)
			[_controller reshape];

		[_openGLContext update];

		CGLUnlockContext([_openGLContext CGLContextObj]);
	}
	//NSLog(@"...reshape");
}


/**
 * Drawing
 */

- (void)prepareOpenGL {
	self.wantsBestResolutionOpenGLSurface = YES;
	_backingFrame = [self convertRectToBacking:[self frame]];
	glViewport(0, 0, _backingFrame.size.width, _backingFrame.size.height);

	glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
	glEnable(GL_MULTISAMPLE);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	self.color = Color2DMake(0.8, 0.8, 0.8, 1);

	_prepared = YES;
}

- (void)drawRect:(NSRect)rect {
	if (_prepared && (!_displayLink || !CVDisplayLinkIsRunning(_displayLink))) {
		CGLLockContext([_openGLContext CGLContextObj]);
		[_openGLContext makeCurrentContext];

		[self draw];

		CGLUnlockContext([_openGLContext CGLContextObj]);
	}
}

- (void)draw {
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	if (_started)
		[_controller draw];

	[_openGLContext flushBuffer];
}


/**
 * Animation
 */

static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext) {
	return [(__bridge View3D *)displayLinkContext getFrameForTime:outputTime];
}

- (CVReturn)getFrameForTime:(const CVTimeStamp*)outputTime {
	if (_started) {
		CGLLockContext([_openGLContext CGLContextObj]);
		[_openGLContext makeCurrentContext];

		double time = CACurrentMediaTime(), delta = time - _last_time;
		_last_time = time;
		@autoreleasepool {
			if ([_controller update:delta])
				[self draw];
		}

		CGLUnlockContext([_openGLContext CGLContextObj]);
	}
	return kCVReturnSuccess;
}

- (void)startAnimation {
	NSAssert(_prepared, @"Starting animation unprepared!");
	CGLLockContext([_openGLContext CGLContextObj]);
	[_openGLContext makeCurrentContext];

	if (_animated)
		[_controller resume];
	_animated = YES;
	_last_time = CACurrentMediaTime();

	CGLUnlockContext([_openGLContext CGLContextObj]);

	//GLint swapInt = 1;
	//[_openGLContext setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
	CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
	CVDisplayLinkSetOutputCallback(_displayLink, &MyDisplayLinkCallback, (__bridge void *)self);
	CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, [_openGLContext CGLContextObj], [_pixelFormat CGLPixelFormatObj]);
	CVDisplayLinkStart(_displayLink);
}

- (void)stopAnimation {
	NSAssert(_prepared && _started, nil);
	CGLLockContext([_openGLContext CGLContextObj]);
	[_openGLContext makeCurrentContext];

	if (_displayLink) {
		CVDisplayLinkStop(_displayLink);
		CVDisplayLinkRelease(_displayLink);
		_displayLink = 0;
	}
	if (_started	 && _animated)
		[_controller stop];

	CGLUnlockContext([_openGLContext CGLContextObj]);
}

- (void)dealloc {
	if (_displayLink)
		[self stopAnimation];
	//[[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewGlobalFrameDidChangeNotification object:self];
}


/**
 * Keyboard events
 */

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)keyDown:(NSEvent *)event {
	NSAssert(_prepared && _started, nil);
	CGLLockContext([_openGLContext CGLContextObj]);
	[_openGLContext makeCurrentContext];

	if ([_controller keyDown:event.keyCode modifiers:(int)event.modifierFlags])
		self.needsDisplay = YES;

	CGLUnlockContext([_openGLContext CGLContextObj]);
}

- (void)keyUp:(NSEvent *)event {
	NSAssert(_prepared && _started, nil);
	CGLLockContext([_openGLContext CGLContextObj]);
	[_openGLContext makeCurrentContext];

	if ([_controller keyUp:event.keyCode modifiers:(int)event.modifierFlags]
	 || [_controller keyPress:[event.charactersIgnoringModifiers characterAtIndex:0] modifiers:(int)event.modifierFlags])
		self.needsDisplay = YES;

	CGLUnlockContext([_openGLContext CGLContextObj]);
}


/**
 * Mouse events
 */

- (void)mouseDown:(NSEvent *)event {
	NSAssert(_prepared && _started, nil);
	CGLLockContext([_openGLContext CGLContextObj]);
	[_openGLContext makeCurrentContext];

	Vector2D location = Vector2DMake([NSEvent mouseLocation].x - _window.frame.origin.x, [NSEvent mouseLocation].y - _window.frame.origin.y);
	if ([_controller touchDown:location modifiers:(int)event.modifierFlags])
		self.needsDisplay = YES;

	CGLUnlockContext([_openGLContext CGLContextObj]);
}

- (void)mouseDragged:(NSEvent *)event {
	NSAssert(_prepared && _started, nil);
	CGLLockContext([_openGLContext CGLContextObj]);
	[_openGLContext makeCurrentContext];

	Vector2D location = Vector2DMake([NSEvent mouseLocation].x - _window.frame.origin.x, [NSEvent mouseLocation].y - _window.frame.origin.y);
	if ([_controller touchMove:location modifiers:(int)event.modifierFlags])
		self.needsDisplay = YES;

	CGLUnlockContext([_openGLContext CGLContextObj]);
}

- (void)mouseUp:(NSEvent *)event {
	NSAssert(_prepared && _started, nil);
	CGLLockContext([_openGLContext CGLContextObj]);
	[_openGLContext makeCurrentContext];

	Vector2D location = Vector2DMake([NSEvent mouseLocation].x - _window.frame.origin.x, [NSEvent mouseLocation].y - _window.frame.origin.y);
	if (_started && [_controller touchUp:location modifiers:(int)event.modifierFlags])
		self.needsDisplay = YES;

	CGLUnlockContext([_openGLContext CGLContextObj]);
}


/**
 * Controller stack
 */

- (Controller3D *)controller {
	return _controller;
}

- (void)pushController:(Controller3D *)controller {
	NSAssert(_prepared, @"Pushing onto unprepared view!");
	if (_controllerStack == nil)
		_controllerStack = [[NSMutableArray alloc] init];
	if (_controller)
		[_controller stop];
	[_controllerStack addObject:controller];
	_controller = controller;
	_controller.view = self;
	//_button = nil;  // TODO
	[_controller start];
	_started = YES;
	self.needsDisplay = YES;
	//NSLog(@"pushed");
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
