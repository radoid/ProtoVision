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
	int _vertexcount, _maxvertexcount, _indexcount, _maxindexcount;
	int _vertexsize, _texcoordssize, _normalsize, _colorsize;
	int _stride;
	BOOL _dynamic;
}

- (id)initWithMode:(GLenum)drawmode vertices:(GLfloat *)vertices vertexCount:(int)vcount indices:(GLushort *)indices indexCount:(int)icount vertexSize:(int)vsize texCoordsSize:(int)tsize normalSize:(int)nsize colorSize:(int)csize isDynamic:(BOOL)isDynamic {
	if (vcount)
		glGenBuffers(1, &_vboname);
	if (icount)
		glGenBuffers(1, &_iboname);
	if ((self = [self initWithMode:drawmode vbo:_vboname vertexCount:vcount ibo:_iboname indexCount:icount vertexSize:vsize texCoordsSize:tsize normalSize:nsize colorSize:csize isDynamic:isDynamic])) {
		if (_vertexcount)
			glBufferData(GL_ARRAY_BUFFER, _vertexcount * _stride, vertices, _dynamic ? GL_DYNAMIC_DRAW : GL_STATIC_DRAW);  // TODO
		if (_indexcount)
			glBufferData(GL_ELEMENT_ARRAY_BUFFER, _indexcount * sizeof(GLshort), indices, _dynamic ? GL_DYNAMIC_DRAW : GL_STATIC_DRAW);  // TODO

		GLenum err; NSAssert(!(err = glGetError()), @"OpenGL error %x", err);
	}
	return self;
}

- (id)initWithMode:(GLenum)drawmode vbo:(GLuint)vbo vertexCount:(int)vcount ibo:(GLuint)ibo indexCount:(int)icount vertexSize:(int)vsize texCoordsSize:(int)tsize normalSize:(int)nsize colorSize:(int)csize isDynamic:(BOOL)isDynamic {
	if ((self = [super init])) {
		_mode = drawmode;
		_vertexcount = _maxvertexcount = vcount;
		_indexcount = _maxindexcount = icount;
		_vertexsize = vsize;
		_texcoordssize = tsize;
		_normalsize = nsize;
		_colorsize = csize;
		_stride = (_vertexsize + _texcoordssize + _normalsize + _colorsize) * sizeof(GLfloat);
		_dynamic = isDynamic;

		glGenVertexArrays(1, &_vao);
		glBindVertexArray(_vao);

		if (vbo) {
			_vboname = vbo;
			glBindBuffer(GL_ARRAY_BUFFER, _vboname);
		}
		if (ibo) {
			_iboname = ibo;
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _iboname);
		}

		GLenum err; NSAssert(!(err = glGetError()), @"[Buffer3D init] OpenGL error %x", err);
		NSAssert(_vao && _vboname && (_iboname || !_indexcount), @"Creating buffers failed!");
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	return [[Buffer3D allocWithZone:zone] initWithMode:_mode vbo:_vboname vertexCount:_vertexcount ibo:_iboname indexCount:_indexcount vertexSize:_vertexsize texCoordsSize:_texcoordssize normalSize:_normalsize colorSize:_colorsize isDynamic:_dynamic];
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

- (void)setAttribForProgram:(Program3D *)program {
	if (program.aPosition > -1 && _vertexsize)
		[self setAttrib:program.aPosition size:_vertexsize type:GL_FLOAT stride:_stride offset:0];
	if (program.aTexture > -1 && _texcoordssize)
		[self setAttrib:program.aTexture size:_texcoordssize type:GL_FLOAT stride:_stride offset:_vertexsize * sizeof(GLfloat)];
	if (program.aNormal > -1 && _normalsize)
		[self setAttrib:program.aNormal size:_normalsize type:GL_FLOAT stride:_stride offset:(_vertexsize + _texcoordssize) * sizeof(GLfloat)];
	if (program.aColor > -1 && _colorsize)
		[self setAttrib:program.aColor size:_colorsize type:GL_FLOAT stride:_stride offset:(_vertexsize + _texcoordssize + _normalsize) * sizeof(GLfloat)];
}

- (void)setAttrib:(int)index size:(int)size type:(int)type stride:(int)stride offset:(int)offset {
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

	GLenum err = glGetError(); NSAssert(!err, @"[Buffer3D draw] OpenGL error %x", err);
}

- (void)dealloc {
	if (_vao)
		glDeleteVertexArrays(1, &_vao);
	//if (vboname)
	//	glDeleteBuffers(1, &vboname);
	//if (iboname)
	//	glDeleteBuffers(1, &iboname);
	//NSLog(@"[Buffer3D dealloc] VBO name %d, IBO name %d", vboname, iboname);
}

@end
