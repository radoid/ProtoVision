//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Program3D.h"
#import "Texture2D.h"


@implementation Program3D

- (id)initWithVertexShader:(NSString *)vs fragmentShader:(NSString *)fs {
	if ((self = [super init])) {
		NSAssert(vs && fs, @"No shader source!");
		GLuint vsname = [self compileSource:vs as:GL_VERTEX_SHADER];
		GLuint fsname = [self compileSource:fs as:GL_FRAGMENT_SHADER];

		_programname = glCreateProgram();
		NSAssert(_programname, @"glCreateProgram failed!");

		glAttachShader(_programname, vsname);
		glAttachShader(_programname, fsname);
		//glBindFragDataLocation(_programname, 0, "fragColor");  // TODO
		glLinkProgram(_programname);

		GLint status, logLen; GLchar *log;
		glGetProgramiv(_programname, GL_INFO_LOG_LENGTH, &logLen);
		if (logLen > 0) {
			glGetProgramInfoLog(_programname, logLen, &logLen, (log = calloc(1, logLen)));
			fprintf(stderr, "%s\n", log);
			NSAssert(NO, @"Shader program link error!");
		}
		glGetProgramiv(_programname, GL_VALIDATE_STATUS, &status);
		NSAssert(!status, @"Invalid program!");

		_uProjection = glGetUniformLocation(_programname, "uProjection");
		_uModelView = glGetUniformLocation(_programname, "uModelView");
		_uNormal = glGetUniformLocation(_programname, "uNormal");
		_uLight = glGetUniformLocation(_programname, "uLight");
		_uEye = glGetUniformLocation(_programname, "uEye");
		_uColor = glGetUniformLocation(_programname, "uColor");
		_uColorLight = glGetUniformLocation(_programname, "uColorLight");
		_uColorDark = glGetUniformLocation(_programname, "uColorDark");
		_uColorSize = glGetUniformLocation(_programname, "uColorSize");
		_uTexture = glGetUniformLocation(_programname, "uTexture");
		_uTexSampler = glGetUniformLocation(_programname, "uTexSampler");
		_uTime = glGetUniformLocation(_programname, "uTime");

		_aPosition = glGetAttribLocation(_programname, "aPosition");
		_aNormal = glGetAttribLocation(_programname, "aNormal");
		_aTexture = glGetAttribLocation(_programname, "aTexture");
		_aColor = glGetAttribLocation(_programname, "aColor");
		_aColorDark = glGetAttribLocation(_programname, "aColorDark");
		_aColorLight = glGetAttribLocation(_programname, "aColorLight");

		glDeleteShader(vsname);
		glDeleteShader(fsname);

		GLint err = glGetError(); NSAssert(!err, @"[Program3D init] OpenGL error %x!", err);
	}
	return self;
}

- (GLuint)compileSource:(NSString *)source as:(GLenum)type {
	const char *cs = [source cStringUsingEncoding:NSUTF8StringEncoding];
	GLuint name = glCreateShader(type);
	NSAssert(name, @"glCreateShader fail");

	glShaderSource(name, 1, &cs, NULL);
	glCompileShader(name);

	GLint status, loglen; GLchar *log;
	glGetShaderiv(name, GL_COMPILE_STATUS, &status);
	if (!status) {
		glGetShaderiv(name, GL_INFO_LOG_LENGTH, &loglen);
		glGetShaderInfoLog(name, loglen, NULL, (log = calloc(1, loglen+1)));
		fprintf(stderr, "%s\n%s\n", log, cs);
	}
	NSAssert(status, @"Shader compile error");

	GLenum err = glGetError(); NSAssert(!err, @"[Program3D compileSource] OpenGL error %x", err);

	return name;
}

+ (int)glslVersion {
	char *version = (char *)glGetString(GL_SHADING_LANGUAGE_VERSION);
	int major;
	if (version)
		if (sscanf(version, "%d", &major) || sscanf(version, "OpenGL ES GLSL ES %d", &major))
			return major;
	return 0;
}

+ (id)programNamed:(NSString *)filename {
	NSBundle *b = [NSBundle bundleWithIdentifier:@"com.radoid.ProtoVisionOSX"];
	if (!b)
		b = [NSBundle bundleWithIdentifier:@"com.radoid.ProtoVisionIOS"];
	for (int i = [Program3D glslVersion]; i >= 0; i--) {
		NSString *version = (i ? [NSString stringWithFormat:@"%@.v%d", filename, i] : filename);
		NSString *vs = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:version ofType:@"vsh"] encoding:NSUTF8StringEncoding error:nil];
		NSString *fs = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:version ofType:@"fsh"] encoding:NSUTF8StringEncoding error:nil];
		if (!vs || !fs) {
			vs = [NSString stringWithContentsOfFile:[b pathForResource:version ofType:@"vsh"] encoding:NSUTF8StringEncoding error:nil];
			fs = [NSString stringWithContentsOfFile:[b pathForResource:version ofType:@"fsh"] encoding:NSUTF8StringEncoding error:nil];
		}
		if (vs && fs)
			return [[Program3D alloc] initWithVertexShader:vs fragmentShader:fs];
	}
	NSAssert(NO, @"No shaders named \"%@\"!", filename);
	return nil;
}

+ (id)defaultProgram {
	static id material;
	if (!material)
		material = [Program3D programNamed:@"default"];
	return material;
}

+ (id)defaultProgram2D {
	static id material2D;
	if (!material2D)
		material2D = [Program3D programNamed:@"unlit"];
	return material2D;
}

- (void)use {
	glUseProgram(_programname);
}

- (void)useWithProjection:(Matrix4x4)projection modelView:(Matrix4x4)modelview normal:(Matrix3x3)normal color:(Color2D)color texture:(Texture2D *)texture light:(Vector3D)direction position:(Vector3D)position {
	[self useWithProjection:projection modelView:modelview normal:normal colorDark:color colorLight:color colorSize:0 texture:texture light:direction position:position];
}

- (void)useWithProjection:(Matrix4x4)projection modelView:(Matrix4x4)modelview normal:(Matrix3x3)normal colorDark:(Color2D)colorDark colorLight:(Color2D)colorLight colorSize:(int)colorSize texture:(Texture2D *)texture light:(Vector3D)direction position:(Vector3D)position {
	glUseProgram(_programname);
	glUniformMatrix4fv(_uProjection, 1, GL_FALSE, (const GLfloat *)&projection);
	glUniformMatrix4fv(_uModelView, 1, GL_FALSE, (const GLfloat *)&modelview);
	glUniformMatrix3fv(_uNormal, 1, GL_FALSE, (const GLfloat *)&normal);
	//glUniform4fv(_uColor, 1, (const GLfloat *)&color);
	glUniform4fv(_uColorDark, 1, (const GLfloat *)&colorDark);
	glUniform4fv(_uColorLight, 1, (const GLfloat *)&colorLight);
	glUniform1i(_uColorSize, colorSize);
	if (_uLight > -1)
		glUniform3fv(_uLight, 1, (const GLfloat *)&direction);
	if (_uEye > -1)
		glUniform3fv(_uEye, 1, (const GLfloat *)&position);
	if (_uTime > -1)
		glUniform1f(_uTime, (float)CACurrentMediaTime());
	if (_uTexture > -1)
		glUniform1i(_uTexture, texture ? GL_TRUE : GL_FALSE);
	if (texture && _uTexture > -1 && _uTexSampler > -1) {
		glUniform1i(_uTexSampler, 0);
		glActiveTexture (GL_TEXTURE0);
		[texture bind];
	}

	GLenum err = glGetError(); NSAssert(!err, @"OpenGL error %x", err);
}

- (void)useWithProjection:(Matrix4x4)projection modelView:(Matrix4x4)modelview color:(Color2D)color texture:(Texture2D *)texture {
	glUseProgram(_programname);
	glUniformMatrix4fv(_uProjection, 1, GL_FALSE, (const GLfloat *)&projection);
	glUniformMatrix4fv(_uModelView, 1, GL_FALSE, (const GLfloat *)&modelview);
	glUniform4fv(_uColor, 1, (const GLfloat *)&color);
	glUniform1i(_uTexture, texture ? GL_TRUE : GL_FALSE);
	if (texture) {
		glUniform1i(_uTexSampler, 0);
		glActiveTexture (GL_TEXTURE0);
		[texture bind];
	}

	GLenum err = glGetError(); NSAssert(!err, @"OpenGL error %x", err);
}

- (void)dealloc {
	if (_programname)
		glDeleteProgram(_programname);
	//NSLog(@"[Program3D dealloc] name %d", _programname);
}

@end
