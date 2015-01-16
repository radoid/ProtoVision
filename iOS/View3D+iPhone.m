//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "View3D+iPhone.h"


@implementation View3D
{
	/* The pixel dimensions of the backbuffer */
	GLint pixelWidth, pixelHeight;

	EAGLContext *context;

	/* OpenGL names for the renderbuffer and framebuffers used to render to this view */
	GLuint renderbuffer, framebuffer;

	/* OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist) */
	BOOL useDepthBuffer;
	GLuint depthRenderbuffer;

	id displayLink;
	NSTimer *timer;

	NSMutableArray *_controllerStack;
	Controller3D *_controller;
	BOOL _initialized, _started, _redrawing;
	Color2D color;
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
	//NSLog(@"[View3D layoutSubviews]");
	//[EAGLContext setCurrentContext:context];  // TODO Sparrow ovo nema
	[self destroyFramebuffer];
	[self createFramebuffer];
	[self draw];
	GLenum err = glGetError(); if (err) NSLog(@"[View3D layoutSubviews] OpenGL ERROR %x", err);
}

- (BOOL)createFramebuffer {
	//NSLog(@"Pozvan createFramebuffer");
	glGenFramebuffers(1, &framebuffer);
	glGenRenderbuffers(1, &renderbuffer);

	glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer);
	[context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderbuffer);

	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &pixelWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &pixelHeight);

	//NSLog(@"glGetRenderbufferParameteriv daje %d x %d", pixelWidth, pixelHeight);

	if (useDepthBuffer) {
		glGenRenderbuffers(1, &depthRenderbuffer);
		glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
		glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, pixelWidth, pixelHeight);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);

		// naknadno ubaceno jer je drugdje redundantno, by Profiler:
		glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer);
	}

	if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
		return NO;
	}

	GLenum err = glGetError(); NSAssert(!err, @"[View3D createFrameBuffer] OpenGL error %x", err);

	return YES;
}

- (void)destroyFramebuffer {
	//NSLog(@"Pozvan destroyFramebuffer");
	if (framebuffer)
		glDeleteFramebuffers(1, &framebuffer);
	framebuffer = 0;
	if (renderbuffer)
		glDeleteRenderbuffers(1, &renderbuffer);
	renderbuffer = 0;
	if (depthRenderbuffer)
		glDeleteRenderbuffers(1, &depthRenderbuffer);
	depthRenderbuffer = 0;

	GLenum err = glGetError(); NSAssert(!err, @"OpenGL error %x", err);  // TODO
}

- (float)scale {
	return self.contentScaleFactor;
}

- (void)draw {
	if (!framebuffer || !renderbuffer)
		return;

	//[EAGLContext setCurrentContext:context];
	// redundantno by Profiler: glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
	GLenum err = glGetError(); NSAssert(!err, @"OpenGL error %x", err);  // TODO

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

		//NSLog(@"[View3D draw] Inicijaliziran EAGLContext, glViewport");
		_initialized = YES;

		GLenum err = glGetError(); NSAssert(!err,@"[View3D draw] OpenGL ERROR %x", err);
	}

	glClear(GL_COLOR_BUFFER_BIT | (useDepthBuffer ? GL_DEPTH_BUFFER_BIT : 0));
	[_controller draw];
	_redrawing = NO;

	// redundantno, by Profiler: glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)setColor:(Color2D)newcolor	{
	color = newcolor;
	glClearColor(color.r, color.g, color.b, 1);
	[self setNeedsDisplay];
}


/**
 * Podrška za animaciju
 */

- (void)startAnimation {
	[EAGLContext setCurrentContext:context];
	if (_initialized) {
		if (!_started)
			[(Controller3D *)_controller start];
		else
			[(Controller3D *)_controller resume];
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
		[(Controller3D *)_controller stop];
}

- (void)loopAnimation {
	if (_initialized) {
		if (!_started) {
			[(Controller3D *)_controller start];
			_started = _redrawing = YES;
		} else
			_redrawing |= [(Controller3D *)_controller update];
	}
	if (_redrawing)
		[self draw];
}


/**
 * Podrška za touch
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
 * Podrška za preorijentaciju
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
 * Sustav kontrolera
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
			[_controller pause];
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
				NSLog(@"[View3D popController:] Stack je već prazan!");
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
