//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Buffer3D.h"


@implementation Buffer3D

/*@synthesize vboname, iboname;
@synthesize mode;
@synthesize vertexcount, indexcount;
@synthesize stride;*/

- (id)initWithMode:(GLenum)drawmode vertices:(GLfloat *)vertices vertexCount:(int)vcount stride:(int)initstride indices:(GLushort *)indices indexCount:(int)icount isDynamic:(BOOL)dynamic {
	if ((self = [super init])) {
		mode = drawmode;
		vertexcount = maxvertexcount = vcount;
		indexcount = maxindexcount = icount;
		stride = initstride;

		glGenVertexArrays(1, &vao);
		glBindVertexArray(vao);

		if (vcount) {
			glGenBuffers(1, &vboname);
			glBindBuffer(GL_ARRAY_BUFFER, vboname);
			glBufferData(GL_ARRAY_BUFFER, vertexcount * stride, vertices, dynamic ? GL_DYNAMIC_DRAW : GL_STATIC_DRAW);  // TODO
			//NSLog(@"[Buffer3D init] VBO name %d", vboname);
		}
		if (icount && indices) {
			glGenBuffers(1, &iboname);
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, iboname);
			glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexcount * sizeof(GLshort), indices, dynamic ? GL_DYNAMIC_DRAW : GL_STATIC_DRAW);  // TODO
			//NSLog(@"[Buffer3D init] IBO name %d", iboname);
		}

		GLenum err; NSAssert(!(err = glGetError()), @"[Buffer3D init] OpenGL error %x", err);

		NSAssert(vao && vboname && (iboname || !indexcount), @"Creating buffers failed!");
	}
	return self;
}

- (void)updateVertices:(Buffer3DVertex *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount  {
/*	if (vcount > maxvertexcount || icount > maxindexcount) {
		if (vboname)
			glDeleteBuffers(1, &vboname);
		if (iboname)
			glDeleteBuffers(1, &iboname);
		NSLog(@"[Buffer3D updateVertexBuffer] Obrisan VBO name %d, IBO name %d", vboname, iboname);
		(void) [self initWithMode:mode vertices:vbuffer vertexCount:vcount indices:ibuffer indexCount:icount isDynamic:YES];
	} else {
		if (vboname && vcount) {
			glBindBuffer(GL_ARRAY_BUFFER, vboname);
			GLvoid *tmpbuffer = glMapBufferRange(GL_ARRAY_BUFFER, 0, vcount * stride, GL_MAP_WRITE_BIT);
			if (tmpbuffer)
				memcpy(tmpbuffer, vbuffer, vcount * stride);
			glUnmapBuffer(GL_ARRAY_BUFFER);
			vertexcount = vcount;
		}
		if (iboname && icount) {
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, iboname);
			GLvoid *tmpbuffer = glMapBufferRange(GL_ELEMENT_ARRAY_BUFFER, 0, vcount * stride, GL_MAP_WRITE_BIT);
			if (tmpbuffer)
				memcpy(tmpbuffer, ibuffer, icount * sizeof(GLshort));
			glUnmapBuffer(GL_ELEMENT_ARRAY_BUFFER);
			indexcount = icount;
		}
	}*/
}

- (void)attrib:(int)index size:(int)size type:(int)type stride:(int)stride offset:(int)offset {
	glEnableVertexAttribArray(index);
	glVertexAttribPointer(index, size, type, GL_FALSE, stride, (const GLvoid *)offset);

	GLenum err; NSAssert(!(err = glGetError()), @"OpenGL error %x", err);
}

- (void)draw {
	glBindVertexArray(vao);

	if (iboname)
		glDrawElements(mode, indexcount, GL_UNSIGNED_SHORT, (const GLvoid *)0);
	else
		glDrawArrays(mode, 0, vertexcount);

	GLenum err = glGetError(); NSAssert(!err, @"[Buffer3D draw] OpenGL error %x", err);
}
/*
- (void)drawWithProjection:(Matrix4x4)projection modelView:(Matrix4x4)modelview normal:(Matrix3x3)normal color:(Color2D)color texture:(Texture2D *)texture light:(Vector3D)direction position:(Vector3D)position {
	[self drawWithProjection:projection modelView:modelview normal:normal colorDark:color colorLight:color texture:texture light:direction position:position];
}

- (void)drawWithProjection:(Matrix4x4)projection modelView:(Matrix4x4)modelview normal:(Matrix3x3)normal colorDark:(Color2D)colorDark colorLight:(Color2D)colorLight texture:(Texture2D *)texture light:(Vector3D)direction position:(Vector3D)position {
	glUseProgram(program.programname);
	glUniformMatrix4fv(program.uProjection, 1, GL_FALSE, (const GLfloat *)&projection);
	glUniformMatrix4fv(program.uModelView, 1, GL_FALSE, (const GLfloat *)&modelview);
	glUniformMatrix3fv(program.uNormal, 1, GL_FALSE, (const GLfloat *)&normal);
	//glUniform4fv(program.uColor, 1, (const GLfloat *)&color);
	glUniform4fv(program.uColorDark, 1, (const GLfloat *)&colorDark);
	glUniform4fv(program.uColorLight, 1, (const GLfloat *)&colorLight);
	if (program.uLight > -1)
		glUniform3fv(program.uLight, 1, (const GLfloat *)&direction);
	if (program.uEye > -1)
		glUniform3fv(program.uEye, 1, (const GLfloat *)&position);
	if (program.uTime > -1)
		glUniform1f(program.uTime, (float)CACurrentMediaTime());
	if (program.uTexture > -1)
		glUniform1i(program.uTexture, texture ? GL_TRUE : GL_FALSE);
	if (texture && program.uTexture > -1 && program.uTexSampler > -1) {
		glUniform1i(program.uTexSampler, 0);
		glActiveTexture (GL_TEXTURE0);
		[texture bind];
	}

	glBindVertexArray(vao);
	//[self enableVertexArrays];
	if (iboname)
		glDrawElements(mode, indexcount, GL_UNSIGNED_SHORT, (const GLvoid *)0);
	else
		glDrawArrays(mode, 0, vertexcount);

	GLenum err = glGetError(); NSAssert(!err, @"[Buffer3D draw] OpenGL error %x", err);
}

- (void)drawWithProjection:(Matrix4x4)projection modelView:(Matrix4x4)modelview color:(Color2D)color texture:(Texture2D *)texture {
	glUseProgram(program.programname);
	glUniformMatrix4fv(program.uProjection, 1, GL_FALSE, (const GLfloat *)&projection);
	glUniformMatrix4fv(program.uModelView, 1, GL_FALSE, (const GLfloat *)&modelview);
	glUniform4fv(program.uColor, 1, (const GLfloat *)&color);
	glUniform1i(program.uTexture, texture ? GL_TRUE : GL_FALSE);
	if (texture) {
		glUniform1i(program.uTexSampler, 0);
		glActiveTexture (GL_TEXTURE0);
		[texture bind];
	}

	glBindVertexArray(vao);
	//[self enableVertexArrays];
	if (iboname)
		glDrawElements(mode, indexcount, GL_UNSIGNED_SHORT, (const GLvoid *)0);
	else
		glDrawArrays(mode, 0, vertexcount);

	GLenum err = glGetError(); NSAssert(!err, @"[Buffer3D draw] OpenGL error %x", err);
}
*/
- (void)dealloc {
	if (vao)
		glDeleteVertexArrays(1, &vao);
	if (vboname)
		glDeleteBuffers(1, &vboname);
	if (iboname)
		glDeleteBuffers(1, &iboname);
	//NSLog(@"[Buffer3D dealloc] VBO name %d, IBO name %d", vboname, iboname);
}

@end
