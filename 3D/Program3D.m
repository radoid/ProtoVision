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
{
	GLuint programname;
	GLint uProjection, uModelView, uNormal;
	GLint uColor, uColorLight, uColorDark, uLight, uEye, uTexture, uTexSampler;
	GLint aPosition, aNormal, aColor, aTexture;
}
@synthesize programname, uProjection, uModelView, uNormal, uColor, uColorDark, uColorLight, uLight, uEye, uTexture, uTexSampler, uTime, aPosition, aNormal, aColor, aTexture;

- (id)initWithVertexShader:(NSString *)vs fragmentShader:(NSString *)fs {
	if ((self = [super init])) {
		NSAssert(vs && fs, @"No shader source!");
		GLuint vsname = [self compileSource:vs as:GL_VERTEX_SHADER];
		GLuint fsname = [self compileSource:fs as:GL_FRAGMENT_SHADER];

		programname = glCreateProgram();
		NSAssert(programname, @"glCreateProgram failed!");

		glAttachShader(programname, vsname);
		glAttachShader(programname, fsname);
		//glBindFragDataLocation(programname, 0, "fragColor");  // TODO
		glLinkProgram(programname);

		GLint status, logLen; GLchar *log;
		glGetProgramiv(programname, GL_INFO_LOG_LENGTH, &logLen);
		if (logLen > 0) {
			glGetProgramInfoLog(programname, logLen, &logLen, (log = calloc(1, logLen)));
			fprintf(stderr, "%s\n", log);
			NSAssert(NO, @"Shader program link error!");
		}
		glGetProgramiv(programname, GL_VALIDATE_STATUS, &status);
		NSAssert(!status, @"Invalid program!");

		uProjection = glGetUniformLocation(programname, "uProjection");
		uModelView = glGetUniformLocation(programname, "uModelView");
		uNormal = glGetUniformLocation(programname, "uNormal");
		uLight = glGetUniformLocation(programname, "uLight");
		uEye = glGetUniformLocation(programname, "uEye");
		uColor = glGetUniformLocation(programname, "uColor");
		uColorLight = glGetUniformLocation(programname, "uColorLight");
		uColorDark = glGetUniformLocation(programname, "uColorDark");
		uTexture = glGetUniformLocation(programname, "uTexture");
		uTexSampler = glGetUniformLocation(programname, "uTexSampler");
		uTime = glGetUniformLocation(programname, "uTime");

		aPosition = glGetAttribLocation(programname, "aPosition");
		aNormal = glGetAttribLocation(programname, "aNormal");
		aColor = glGetAttribLocation(programname, "aColor");
		aTexture = glGetAttribLocation(programname, "aTexture");

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
	for (int i = [Program3D glslVersion]; i >= 0; i--) {
		NSString *version = (i ? [NSString stringWithFormat:@"%@.v%d", filename, i] : filename);
		NSString *vs = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:version ofType:@"vsh"] encoding:NSUTF8StringEncoding error:nil];
		NSString *fs = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:version ofType:@"fsh"] encoding:NSUTF8StringEncoding error:nil];
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
	glUseProgram(programname);
}

- (void)useWithProjection:(Matrix4x4)projection modelView:(Matrix4x4)modelview normal:(Matrix3x3)normal color:(Color2D)color texture:(Texture2D *)texture light:(Vector3D)direction position:(Vector3D)position {
	[self useWithProjection:projection modelView:modelview normal:normal colorDark:color colorLight:color texture:texture light:direction position:position];
}

- (void)useWithProjection:(Matrix4x4)projection modelView:(Matrix4x4)modelview normal:(Matrix3x3)normal colorDark:(Color2D)colorDark colorLight:(Color2D)colorLight texture:(Texture2D *)texture light:(Vector3D)direction position:(Vector3D)position {
	glUseProgram(programname);
	glUniformMatrix4fv(uProjection, 1, GL_FALSE, (const GLfloat *)&projection);
	glUniformMatrix4fv(uModelView, 1, GL_FALSE, (const GLfloat *)&modelview);
	glUniformMatrix3fv(uNormal, 1, GL_FALSE, (const GLfloat *)&normal);
	//glUniform4fv(uColor, 1, (const GLfloat *)&color);
	glUniform4fv(uColorDark, 1, (const GLfloat *)&colorDark);
	glUniform4fv(uColorLight, 1, (const GLfloat *)&colorLight);
	if (uLight > -1)
		glUniform3fv(uLight, 1, (const GLfloat *)&direction);
	if (uEye > -1)
		glUniform3fv(uEye, 1, (const GLfloat *)&position);
	if (uTime > -1)
		glUniform1f(uTime, (float)CACurrentMediaTime());
	if (uTexture > -1)
		glUniform1i(uTexture, texture ? GL_TRUE : GL_FALSE);
	if (texture && uTexture > -1 && uTexSampler > -1) {
		glUniform1i(uTexSampler, 0);
		glActiveTexture (GL_TEXTURE0);
		[texture bind];
	}

	GLenum err = glGetError(); NSAssert(!err, @"OpenGL error %x", err);
}

- (void)useWithProjection:(Matrix4x4)projection modelView:(Matrix4x4)modelview color:(Color2D)color texture:(Texture2D *)texture {
	glUseProgram(programname);
	glUniformMatrix4fv(uProjection, 1, GL_FALSE, (const GLfloat *)&projection);
	glUniformMatrix4fv(uModelView, 1, GL_FALSE, (const GLfloat *)&modelview);
	glUniform4fv(uColor, 1, (const GLfloat *)&color);
	glUniform1i(uTexture, texture ? GL_TRUE : GL_FALSE);
	if (texture) {
		glUniform1i(uTexSampler, 0);
		glActiveTexture (GL_TEXTURE0);
		[texture bind];
	}

	GLenum err = glGetError(); NSAssert(!err, @"OpenGL error %x", err);
}

- (void)dealloc {
	if (programname)
		glDeleteProgram(programname);
	//NSLog(@"[Program3D dealloc] name %d", programname);
}

@end
