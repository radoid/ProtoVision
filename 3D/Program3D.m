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
			//NSAssert(NO, @"Shader program link error!");
		}
		glGetProgramiv(_programname, GL_VALIDATE_STATUS, &status);
		NSAssert(!status, @"Invalid program!");

		_uProjection = glGetUniformLocation(_programname, "uProjection");
		_uModel = glGetUniformLocation(_programname, "uModel");
		_uModelView = glGetUniformLocation(_programname, "uModelView");
		_uNormal = glGetUniformLocation(_programname, "uNormal");
		_uLightCount = glGetUniformLocation(_programname, "uLightCount");
		_uLight = glGetUniformLocation(_programname, "uLight");
		_uEye = glGetUniformLocation(_programname, "uEye");
		_uTime = glGetUniformLocation(_programname, "uTime");
		_uColor = glGetUniformLocation(_programname, "uColor");
		_uColorAmbient = glGetUniformLocation(_programname, "uColorAmbient");
		_uColorSpecular = glGetUniformLocation(_programname, "uColorSpecular");
		_uColorSize = glGetUniformLocation(_programname, "uColorSize");
		_uUseColorMap = glGetUniformLocation(_programname, "uUseColorMap");
		_uColorMapSampler = glGetUniformLocation(_programname, "uColorMapSampler");
		_uUseNormalMap = glGetUniformLocation(_programname, "uUseNormalMap");
		_uNormalMapSampler = glGetUniformLocation(_programname, "uNormalMapSampler");
		_uUseSpecularMap = glGetUniformLocation(_programname, "uUseSpecularMap");
		_uSpecularMapSampler = glGetUniformLocation(_programname, "uSpecularMapSampler");
		_uUseAmbientOcclusionMap = glGetUniformLocation(_programname, "uUseAmbientOcclusionMap");
		_uAmbientOcclusionMapSampler = glGetUniformLocation(_programname, "uAmbientOcclusionMapSampler");

		_aPosition = glGetAttribLocation(_programname, "aPosition");
		_aNormal = glGetAttribLocation(_programname, "aNormal");
		_aTangent = glGetAttribLocation(_programname, "aTangent");
		_aColor = glGetAttribLocation(_programname, "aColor");
		_aColorAmbient = glGetAttribLocation(_programname, "aColorAmbient");
		_aColor = glGetAttribLocation(_programname, "aColor");
		_aTextureUV = glGetAttribLocation(_programname, "aTextureUV");

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
		material = [Program3D programNamed:@"vertex"];
	return material;
}

+ (id)defaultProgram2D {
	static id material2D;
	if (!material2D)
		material2D = [Program3D programNamed:@"vertex"];
	return material2D;
}

- (void)use {
	glUseProgram(_programname);
}

- (void)useWithProjection:(Matrix4x4)projection model:(Matrix4x4)model view:(Matrix4x4)view modelView:(Matrix4x4)modelview normal:(Matrix3x3)normal color:(Color2D)color colorAmbient:(Color2D)colorAmbient colorSpecular:(Color2D)colorSpecular colorSize:(int)colorSize colorMap:(Texture2D *)colorMap normalMap:(Texture2D *)normalMap specularMap:(Texture2D *)specularMap ambientOcclusionMap:(Texture2D *)ambientOcclusionMap light:(Vector3D)direction position:(Vector3D)position {
	glUseProgram(_programname);
	glUniformMatrix4fv(_uProjection, 1, GL_FALSE, (const GLfloat *)&projection);
	glUniformMatrix4fv(_uModel, 1, GL_FALSE, (const GLfloat *)&model);
	glUniformMatrix4fv(_uModelView, 1, GL_FALSE, (const GLfloat *)&modelview);
	glUniformMatrix3fv(_uNormal, 1, GL_FALSE, (const GLfloat *)&normal);
	if (_uLightCount > -1 && _uLight > -1)
		glUniform1i(_uLightCount, 1);
	if (_uLight > -1)
		glUniform3fv(_uLight, 1, (const GLfloat *)&direction);
	if (_uEye > -1)
		glUniform3fv(_uEye, 1, (const GLfloat *)&position);
	if (_uTime > -1)
		glUniform1f(_uTime, (float)CACurrentMediaTime());

	glUniform4fv(_uColor, 1, (const GLfloat *)&color);
	glUniform4fv(_uColorAmbient, 1, (const GLfloat *)&colorAmbient);
	glUniform4fv(_uColorSpecular, 1, (const GLfloat *)&colorSpecular);
	glUniform1i(_uColorSize, colorSize);

	if (_uUseColorMap > -1)
		glUniform1i(_uUseColorMap, colorMap && _uColorMapSampler > -1 ? GL_TRUE : GL_FALSE);
	if (colorMap && _uColorMapSampler > -1) {
		glUniform1i(_uColorMapSampler, 0);
		glActiveTexture(GL_TEXTURE0);
		[colorMap bind];
	}

	if (_uUseNormalMap > -1)
		glUniform1i(_uUseNormalMap, normalMap && _uNormalMapSampler > -1 ? GL_TRUE : GL_FALSE);
	if (normalMap && _uNormalMapSampler > -1) {
		glUniform1i(_uNormalMapSampler, 1);
		glActiveTexture(GL_TEXTURE1);
		[normalMap bind];
	}

	if (_uUseSpecularMap > -1)
		glUniform1i(_uUseSpecularMap, specularMap && _uSpecularMapSampler > -1 ? GL_TRUE : GL_FALSE);
	if (specularMap && _uSpecularMapSampler > -1) {
		glUniform1i(_uSpecularMapSampler, 2);
		glActiveTexture(GL_TEXTURE2);
		[specularMap bind];
	}

	if (_uUseAmbientOcclusionMap > -1)
		glUniform1i(_uUseAmbientOcclusionMap, ambientOcclusionMap && _uAmbientOcclusionMapSampler > -1 ? GL_TRUE : GL_FALSE);
	if (ambientOcclusionMap && _uAmbientOcclusionMapSampler > -1) {
		glUniform1i(_uAmbientOcclusionMapSampler, 3);
		glActiveTexture(GL_TEXTURE3);
		[ambientOcclusionMap bind];
	}

	GLenum err = glGetError(); NSAssert(!err, @"OpenGL error %x", err);
}

- (void)useWithProjection:(Matrix4x4)projection modelView:(Matrix4x4)modelview color:(Color2D)color texture:(Texture2D *)texture {
	glUseProgram(_programname);
	glUniformMatrix4fv(_uProjection, 1, GL_FALSE, (const GLfloat *)&projection);
	glUniformMatrix4fv(_uModelView, 1, GL_FALSE, (const GLfloat *)&modelview);
	glUniform4fv(_uColor, 1, (const GLfloat *)&color);
	if (_uLightCount > -1)
		glUniform1i(_uLightCount, 0);
	if (_uUseColorMap > -1)
		glUniform1i(_uUseColorMap, texture ? GL_TRUE : GL_FALSE);
	if (texture && _uColorMapSampler > -1) {
		glUniform1i(_uColorMapSampler, 0);
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
