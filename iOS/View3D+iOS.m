//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "View3D+iOS.h"


@implementation View3D
{
	EAGLContext *context;
	GLuint framebuffer, renderbuffer, depthbuffer;

	/* The pixel dimensions of the backbuffer */
	GLint pixelWidth, pixelHeight;
	/* OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist) */
	BOOL useDepthBuffer;

	id displayLink;
	NSTimer *timer;

	NSMutableArray *_controllerStack;
	Controller3D *_controller;
	BOOL _initialized, _started, _redrawing;
	Color2D color;
	double last_time;
}
@synthesize color;

+ (Class)layerClass {
	return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)rect {
	return [self initWithFrame:rect useHighResolution:YES useDepthBuffer:YES];
}

- (id)initWithFrame:(CGRect)rect useHighResolution:(BOOL)retina useDepthBuffer:(BOOL)depth {
	if ((self = [super initWithFrame:rect])) {
		useDepthBuffer = depth;
		CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		eaglLayer.opaque = YES;
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		if (!context)
			context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		if (!context || ![EAGLContext setCurrentContext:context]) {
			NSLog(@"[View3D initWithFrame] EAGLContext creation failed!");
			return nil;
		}

		if (retina && [UIScreen mainScreen].currentMode.size.width == 2*[UIScreen mainScreen].bounds.size.width && [self respondsToSelector:@selector(contentScaleFactor)]) {
			//NSLog(@"[View3D initWithFrame] Retina - contentScaleFactor=2 :)");
			self.contentScaleFactor = 2;
			//[self layoutSubviews];
			GLenum err = glGetError(); if (err) NSLog(@"[View3D initWithFrame] Open GL ERROR %x", err);
		}
		//else NSLog(@"[View3D initWithFrame] Nije retina ekran! :(");
		color = Color2DMake(.8, .8, .8, 1);
	}

	GLenum err = glGetError(); NSAssert(!err, @"OpenGL error %x", err);  // TODO

	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
	//[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

	return self;
}

- (id)initWithCoder:(NSCoder*)coder {
	if ((self = [super initWithCoder:coder]))
		self = [self initWithFrame:[[UIScreen mainScreen] bounds] useHighResolution:YES useDepthBuffer:YES];
	return self;
}

- (void)layoutSubviews {
	[EAGLContext setCurrentContext:context];  // TODO

	if (framebuffer)
		glDeleteFramebuffers(1, &framebuffer);
	if (renderbuffer)
		glDeleteRenderbuffers(1, &renderbuffer);
	if (depthbuffer)
		glDeleteRenderbuffers(1, &depthbuffer);

	glGenFramebuffers(1, &framebuffer);
	glGenRenderbuffers(1, &renderbuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer);
	[context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderbuffer);

	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &pixelWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &pixelHeight);

	if (useDepthBuffer) {
		glGenRenderbuffers(1, &depthbuffer);
		glBindRenderbuffer(GL_RENDERBUFFER, depthbuffer);
		glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, pixelWidth, pixelHeight);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthbuffer);

		glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer);  // TODO
	}

	GLenum err; NSAssert(!(err = glGetError()), @"[View3D layoutSubviews] OpenGL error %x", err);

	NSAssert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, @"Framebuffer failed to complete!");

	[self setNeedsDisplay];
}

- (float)scale {
	return self.contentScaleFactor;
}

- (void)draw {
	if (!framebuffer || !renderbuffer)
		return;

	//[EAGLContext setCurrentContext:context];  // TODO

	if (!_initialized) {
		[EAGLContext setCurrentContext:context];
		glViewport(self.frame.origin.x * self.contentScaleFactor, self.frame.origin.y * self.contentScaleFactor, self.frame.size.width * self.contentScaleFactor, self.frame.size.height * self.contentScaleFactor);
		glEnable(GL_DEPTH_TEST);
		glEnable(GL_CULL_FACE);
		//glDepthFunc(GL_LEQUAL);
		//glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		//glEnable(GL_TEXTURE_2D);
		//glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND_SRC);
		//glEnableClientState(GL_VERTEX_ARRAY);
		//glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glClearColor(color.r, color.g, color.b, 1);

		_initialized = YES;
	}

	glClear(GL_COLOR_BUFFER_BIT | (depthbuffer ? GL_DEPTH_BUFFER_BIT : 0));
	[_controller draw];
	_redrawing = NO;

	//glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);  // TODO
	[context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)setColor:(Color2D)newcolor	{
	color = newcolor;
	glClearColor(color.r, color.g, color.b, 1);
	[self setNeedsDisplay];
}


/**
 * Animation
 */

- (void)startAnimation {
	[EAGLContext setCurrentContext:context];
	if (_initialized) {
		if (!_started)
			[_controller start];
		else
			[_controller resume];
		_started = _redrawing = YES;
	}
	GLenum err = glGetError(); NSAssert(!err, @"OpenGL error %x", err);  // TODO

	if (displayLink || timer)
		return;
	//NSLog(@"[View3D start] CADisplayLink starts");
	displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(loopAnimation)];
	[displayLink setFrameInterval:2];
	[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stopAnimation {
	//NSLog(@"[View3D stop]");
	if (displayLink)
		[displayLink invalidate];
	if (timer)
		[timer invalidate];
	displayLink = timer = nil;

	if (_started)
		[_controller stop];
}

- (void)loopAnimation {
	NSAssert(_started, @"loopAnimation before start!"); // TODO
	double time = CACurrentMediaTime(), delta = time - last_time;
	last_time = time;
	if (_initialized) {
		if (!_started) {
			[_controller start];
			_started = _redrawing = YES;
		} else
			_redrawing |= [_controller update:delta];
	}
	if (_redrawing)
		[self setNeedsDisplay];
}


/**
 * Touch events
 */

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	CGRect bounds = [self bounds];
	UITouch* touch = [[event touchesForView:self] anyObject];
	//firstTouch = YES;
	CGPoint location = [touch locationInView:self];
	location.y = bounds.size.height - location.y;
	_redrawing |= [_controller touchDown:Vector2DMake(location.x, location.y)];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	CGRect bounds = [self bounds];
	UITouch* touch = [[event touchesForView:self] anyObject];
	//firstTouch = YES;
	CGPoint location = [touch locationInView:self];
	location.y = bounds.size.height - location.y;
	_redrawing |= [_controller touchMove:Vector2DMake(location.x, location.y)];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	CGRect bounds = [self bounds];
	UITouch* touch = [[event touchesForView:self] anyObject];
	//firstTouch = YES;
	CGPoint location = [touch locationInView:self];
	location.y = bounds.size.height - location.y;
	_redrawing |= [_controller touchUp:Vector2DMake(location.x, location.y)];
}


/**
 * Orientation changes
 */

- (void)orientationDidChange:(NSNotification *)note {
	//UIDeviceOrientation ori = [[UIDevice currentDevice] orientation];
	//NSLog(@"[View3D orientationDidChange]: Nova orijentacija: %d", ori);
	/*float angle = (ori == UIDeviceOrientationPortrait ? 0 :
	 (ori == UIDeviceOrientationPortraitUpsideDown ? 180 :
	 (ori == UIDeviceOrientationLandscapeLeft ? 90 :
	 (ori == UIDeviceOrientationLandscapeRight ? 270 : -1))));
	 if (ori >= 0)
	 [[GameController controller] orientation:angle];*/
}


/**
 * Controller stack
 */

- (id)controller {
	@synchronized (_controllerStack) {
		return _controller;
	}
}

- (void)pushController:(Controller3D *)newcontroller {
	@synchronized (_controllerStack) {
		if (_controllerStack == nil)
			_controllerStack = [[NSMutableArray alloc] init];
		if (_controller)
			[_controller stop];
		[_controllerStack addObject:newcontroller];
		_controller = newcontroller;
		_controller.view = self;
		//_button = nil;  // TODO
		if (_started) {
			[_controller start];
			_redrawing = YES;
		}
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
				NSLog(@"[View3D popController:] Stack already empty!");
				_controllerStack = nil;
			}
			_redrawing = YES;
		}
	}
}


- (void)dealloc {
	[self stopAnimation];

	if ([EAGLContext currentContext] == context)
		[EAGLContext setCurrentContext:nil];
}

@end
