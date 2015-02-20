//
// Created by Ante on 15/02/2015.
// Copyright (c) 2015 Radoid. All rights reserved.
//

#import "ProtoVision.h"
#import "FrameBuffer3D.h"


@implementation FrameBuffer3D
{
	GLuint _name, _texture;
	int _width, _height;
}

- (id)initWithWidth:(int)width height:(int)height {
	if ((self = [super init])) {
		_width = width;
		_height = height;

		glGenFramebuffers(1, &_name);
		glBindFramebuffer(GL_FRAMEBUFFER, _name);

		glGenTextures(1, &_texture);
		glBindTexture(GL_TEXTURE_2D, _texture);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, _width, _height, 0, GL_DEPTH_COMPONENT, GL_FLOAT, 0);  // TODO GL_UNSIGNED_INT
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_FUNC, GL_LEQUAL);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE, GL_COMPARE_REF_TO_TEXTURE);
		glBindTexture(GL_TEXTURE_2D, 0);

		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, _texture, 0);

		glDrawBuffer(GL_NONE);
		glReadBuffer(GL_NONE);

		GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
		NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"OpenGL error 0x%x", status);

		glBindFramebuffer(GL_FRAMEBUFFER, 0);
		GLenum err; NSAssert(!(err = glGetError()), @"OpenGL error 0x%x", err);
	}
	return self;
}

- (void)bind {
	glEnable(GL_DEPTH_TEST);
	glDisable(GL_CULL_FACE);
	glBindFramebuffer(GL_FRAMEBUFFER, _name);
	glViewport(0, 0, _width, _height);
	glClear(GL_DEPTH_BUFFER_BIT);
	GLenum err; NSAssert(!(err = glGetError()), @"OpenGL error 0x%x", err);
}

- (void)unbind {
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
	glEnable(GL_CULL_FACE);
	GLenum err; NSAssert(!(err = glGetError()), @"OpenGL error 0x%x", err);
}

- (void)dealloc {
	glDeleteTextures(1, &_texture);
	glDeleteFramebuffers(1, &_name);
}

@end