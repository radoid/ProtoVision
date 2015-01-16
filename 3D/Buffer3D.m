//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Buffer3D.h"


@implementation Buffer3D

- (id)initWithProgram:(Program3D *)initprogram mode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vsize texCoordsSize:(int)tsize normalSize:(int)nsize colorSize:(int)csize isDynamic:(BOOL)dynamic {
	if ((self = [super init])) {
		NSAssert(initprogram, @"Initializing Buffer3D with no program!");
		
		mode = drawmode;
		vertexcount = maxvertexcount = vcount;
		indexcount = maxindexcount = icount;
		vertexsize = vsize;
		texcoordssize = tsize;
		normalsize = nsize;
		colorsize = csize;
		stride = (vertexsize+texcoordssize+normalsize+colorsize) * sizeof(GLfloat);

		glGenVertexArrays(1, &vao);
		glBindVertexArray(vao);

		if (vcount && vbuffer) {
			glGenBuffers(1, &vboname);
			glBindBuffer(GL_ARRAY_BUFFER, vboname);
			glBufferData(GL_ARRAY_BUFFER, vertexcount * stride, vbuffer, dynamic ? GL_DYNAMIC_DRAW : GL_STATIC_DRAW);  // TODO
			//NSLog(@"[Buffer3D init] VBO name %d", vboname);
		}
		if (icount && ibuffer) {
			glGenBuffers(1, &iboname);
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, iboname);
			glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexcount * sizeof(GLshort), ibuffer, dynamic ? GL_DYNAMIC_DRAW : GL_STATIC_DRAW);  // TODO
			//NSLog(@"[Buffer3D init] IBO name %d", iboname);
		}

		program = initprogram;
		[self enableVertexArrays];

		GLenum err; NSAssert(!(err = glGetError()), @"[Buffer3D init] OpenGL error %x", err);
	}
	return self;
}

- (id)initWithMode:(GLenum)drawmode vertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount vertexSize:(int)vsize texCoordsSize:(int)tsize normalSize:(int)nsize colorSize:(int)csize isDynamic:(BOOL)dynamic {
	return [self initWithProgram:[Program3D defaultProgram] mode:drawmode vertices:(GLfloat *)vbuffer vertexCount:vcount indices:ibuffer indexCount:icount vertexSize:vsize texCoordsSize:tsize normalSize:nsize colorSize:csize isDynamic:dynamic];
}

- (id)initWithMode:(GLenum)drawmode vertices:(Buffer3DVertex *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount isDynamic:(BOOL)dynamic {
	return [self initWithMode:drawmode vertices:(GLfloat *)vbuffer vertexCount:vcount indices:ibuffer indexCount:icount vertexSize:3 texCoordsSize:2 normalSize:3 colorSize:0 isDynamic:dynamic];
}

- (id)initWithNormalsCalculatedAsSharp:(BOOL)sharpen vertexBuffer:(Buffer3DVertex *)vertices vertexCount:(int)vcount indices:(GLushort *)indices indexCount:(int)icount isDynamic:(BOOL)dynamic {
	for (int i=0; i < icount; i += 3) {
		Vector3D a = vertices[indices[i+0]].vertex;
		Vector3D b = vertices[indices[i+1]].vertex;
		Vector3D c = vertices[indices[i+2]].vertex;
		Vector3D normal = Vector3DUnit(Vector3DCross(Vector3DSubtract(b, a), Vector3DSubtract(c, b)));
		if (sharpen) {
			vertices[indices[i+0]].normal = normal;
			vertices[indices[i+1]].normal = normal;
			vertices[indices[i+2]].normal = normal;
		} else {
			vertices[indices[i+0]].normal = Vector3DAdd(normal, vertices[indices[i+0]].normal);
			vertices[indices[i+1]].normal = Vector3DAdd(normal, vertices[indices[i+1]].normal);
			vertices[indices[i+2]].normal = Vector3DAdd(normal, vertices[indices[i+2]].normal);
		}
	}
	if (!sharpen)
		for (int i=0; i < vcount; i++)
			vertices[i].normal = Vector3DUnit(vertices[i].normal);
	return [self initWithMode:GL_TRIANGLES vertices:vertices vertexCount:vcount indices:indices indexCount:icount isDynamic:dynamic];
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

- (void)enableVertexArrays {
	glUseProgram(program.programname);
	if (program.aPosition > -1) {
		glEnableVertexAttribArray(program.aPosition);
		glVertexAttribPointer(program.aPosition, vertexsize, GL_FLOAT, GL_FALSE, stride, (const GLvoid *)0);
	}
	if (program.aTexture > -1 && texcoordssize) {
		glEnableVertexAttribArray(program.aTexture);
		glVertexAttribPointer(program.aTexture, texcoordssize, GL_FLOAT, GL_FALSE, stride, (const GLvoid *)(vertexsize * sizeof(GLfloat)));
	}
	//vertexsize * sizeof(GLfloat)
	if (program.aNormal > -1 && normalsize) {
		glEnableVertexAttribArray(program.aNormal);
		glVertexAttribPointer(program.aNormal, normalsize, GL_FLOAT, GL_FALSE, stride, (const GLvoid *)((vertexsize+texcoordssize) * sizeof(GLfloat)));
	}
	if (program.aColor > -1 && colorsize) {
		glEnableVertexAttribArray(program.aColor);
		glVertexAttribPointer(program.aColor, colorsize, GL_FLOAT, GL_FALSE, stride, (const GLvoid *)((vertexsize+texcoordssize+normalsize) * sizeof(GLfloat)));
	}

	GLenum err = glGetError(); NSAssert(!err, @"[Buffer3D enableVertexArrays] OpenGL error %x", err);
}

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
