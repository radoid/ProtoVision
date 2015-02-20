//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Buffer3D.h"


@implementation Buffer3D
{
	GLuint _vao;
	GLuint _vboname, _iboname;
	GLenum _mode;
	int _maxvertexcount, _maxindexcount;
	int _stride;
	BOOL _dynamic;
}

- (id)initWithMode:(GLenum)drawmode vertices:(GLfloat *)vertices vertexCount:(int)vcount indices:(GLushort *)indices indexCount:(int)icount vertexSize:(int)vsize texCoordsSize:(int)tsize normalSize:(int)nsize tangentSize:(int)tansize colorSize:(int)csize isDynamic:(BOOL)isDynamic {
	glBindVertexArray(0);
	_vboname = 0;
	if (vcount)
		glGenBuffers(1, &_vboname);
	_iboname = 0;
	if (icount)
		glGenBuffers(1, &_iboname);
	if ((self = [self initWithMode:drawmode vbo:_vboname vertexCount:vcount ibo:_iboname indexCount:icount vertexSize:vsize texCoordsSize:tsize normalSize:nsize tangentSize:tansize colorSize:csize isDynamic:isDynamic])) {
		if (_vertexcount)
			glBufferData(GL_ARRAY_BUFFER, _vertexcount * _stride, vertices, _dynamic ? GL_DYNAMIC_DRAW : GL_STATIC_DRAW);  // TODO
		if (_indexcount)
			glBufferData(GL_ELEMENT_ARRAY_BUFFER, _indexcount * sizeof(GLushort), indices, _dynamic ? GL_DYNAMIC_DRAW : GL_STATIC_DRAW);  // TODO

		GLenum err; NSAssert(!(err = glGetError()), @"OpenGL error %x", err);
	}
	return self;
}

- (id)initWithMode:(GLenum)drawmode vbo:(GLuint)vbo vertexCount:(int)vcount ibo:(GLuint)ibo indexCount:(int)icount vertexSize:(int)vsize texCoordsSize:(int)tsize normalSize:(int)nsize tangentSize:(int)tansize colorSize:(int)csize isDynamic:(BOOL)isDynamic {
	if ((self = [super init])) {
		_mode = drawmode;
		_vertexcount = _maxvertexcount = vcount;
		_indexcount = _maxindexcount = icount;
		_vertexsize = vsize;
		_texcoordssize = tsize;
		_normalsize = nsize;
		_tangentsize = tansize;
		_colorsize = csize;
		_stride = (_vertexsize + _texcoordssize + _normalsize + _tangentsize + _colorsize) * sizeof(GLfloat);
		_dynamic = isDynamic;

		glGenVertexArrays(1, &_vao);
		glBindVertexArray(_vao);

		_vboname = vbo;
		//if (_vboname)
			glBindBuffer(GL_ARRAY_BUFFER, _vboname);
		_iboname = ibo;
		//if (_iboname)
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _iboname);

		//NSLog(@"vao %d, vbo %d, ibo %d", _vao, _vboname, _iboname);

		GLenum err; NSAssert(!(err = glGetError()), @"OpenGL error %x", err);
		NSAssert(_vao && _vboname && (_iboname || !_indexcount), @"Creating buffers failed!");
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	return [[Buffer3D allocWithZone:zone] initWithMode:_mode vbo:_vboname vertexCount:_vertexcount ibo:_iboname indexCount:_indexcount vertexSize:_vertexsize texCoordsSize:_texcoordssize normalSize:_normalsize tangentSize:0 colorSize:_colorsize isDynamic:_dynamic];
}

- (void)updateVertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount  {
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
				memcpy(tmpbuffer, ibuffer, icount * sizeof(GLushort));
			glUnmapBuffer(GL_ELEMENT_ARRAY_BUFFER);
			indexcount = icount;
		}
	}*/
}

- (void)setAttribArraysFromProgram:(Program3D *)program {
	if (program.aPosition > -1 && _vertexsize)
		[self setAttribArray:program.aPosition size:_vertexsize type:GL_FLOAT stride:_stride offset:0];
	if (program.aTextureUV > -1 && _texcoordssize)
		[self setAttribArray:program.aTextureUV size:_texcoordssize type:GL_FLOAT stride:_stride offset:_vertexsize * sizeof(GLfloat)];
	if (program.aNormal > -1 && _normalsize)
		[self setAttribArray:program.aNormal size:_normalsize type:GL_FLOAT stride:_stride offset:(_vertexsize + _texcoordssize) * sizeof(GLfloat)];
	if (program.aTangent > -1 && _tangentsize)
		[self setAttribArray:program.aTangent size:_tangentsize type:GL_FLOAT stride:_stride offset:(_vertexsize + _texcoordssize + _normalsize) * sizeof(GLfloat)];
	if (_colorsize == 8 && program.aColorAmbient > -1 && program.aColor > -1) {
		[self setAttribArray:program.aColorAmbient size:4 type:GL_FLOAT stride:_stride offset:(_vertexsize + _texcoordssize + _normalsize + _tangentsize) * sizeof(GLfloat)];
		[self setAttribArray:program.aColor size:4 type:GL_FLOAT stride:_stride offset:(_vertexsize + _texcoordssize + _normalsize + _tangentsize + 4) * sizeof(GLfloat)];
	} else if (_colorsize == 4 && program.aColor > -1)
		[self setAttribArray:program.aColor size:_colorsize type:GL_FLOAT stride:_stride offset:(_vertexsize + _texcoordssize + _normalsize + _tangentsize) * sizeof(GLfloat)];
	else if (_colorsize == 1 && program.aColorIndex > -1)
		[self setAttribArray:program.aColorIndex size:_colorsize type:GL_INT stride:_stride offset:(_vertexsize + _texcoordssize + _normalsize + _tangentsize) * sizeof(GLfloat)];
}

- (void)setAttribArray:(int)index size:(int)size type:(int)type stride:(int)stride offset:(int)offset {
	glBindVertexArray(_vao);
	glBindBuffer(GL_ARRAY_BUFFER, _vboname);
	glEnableVertexAttribArray(index);
	glVertexAttribPointer(index, size, type, GL_FALSE, stride, (const GLvoid *)offset);

	GLenum err; NSAssert(!(err = glGetError()), @"OpenGL error %x", err);
}

- (void)draw {
	glBindVertexArray(_vao);

	if (_iboname)
		glDrawElements(_mode, _indexcount, GL_UNSIGNED_SHORT, (const GLvoid *)0);
	else if (_vboname)
		glDrawArrays(_mode, 0, _vertexcount);

	GLenum err; NSAssert(!(err = glGetError()), @"[Buffer3D draw] OpenGL error 0x%x", err);
}

- (void)dealloc {
	if (_vao)
		glDeleteVertexArrays(1, &_vao);
	//if (vboname)
	//	glDeleteBuffers(1, &vboname);
	//if (iboname)
	//	glDeleteBuffers(1, &iboname);
	//NSLog(@"[Buffer3D dealloc] VAO %d, VBO %d, IBO %d", _vao, _vboname, _iboname);
}

@end
