//
// Created by Ante on 04/02/2015.
// Copyright (c) 2015 Radoid. All rights reserved.
//

#import "Disc3D.h"


typedef struct {
	GLfloat position[3], texcoords[2], normal[3], tangent[3];
} Vertex;


@implementation Disc3D

- (id)initWithRadius:(float)radius height:(float)height levels:(int)n {
	Vertex vertices[(n+1)*2];
	int m = 0;
	for (int side = +1; side >= -1; side -= 2) {
		vertices[m++] = (Vertex) {0, side*height/2, 0, 0.5, 0.5, 0, side, 0, -side, 0, 0};
		for (int a=0; a < n; a++) {
			float vx = cosf(a * 2*M_PI / n);
			float vz = sinf(a * 2*M_PI / n);
			vertices[m++] = (Vertex) {radius * vx, side*height/2, -radius * vz, 0.5+vx*0.5, 0.5+vz*0.5, 0, side, 0, -side, 0, 0};
		}
	}

	GLushort indices[(n+1)*2 * 2 + 2 + 2 + (n+1)*2];
	m = 0;
	for (int a=0; a < n; a++) {
		indices[m++] = 0;
		indices[m++] = 1+a+0;
	}
	indices[m++] = 0;
	indices[m++] = 1;

	indices[m++] = 1; // zero after top circle
	indices[m++] = n+1 + 1+0+0; // zero before bottom circle

	for (int a=0; a < n; a++) {
		indices[m++] = n+1 + 1+a+0;
		indices[m++] = n+1 + 0;
	}
	indices[m++] = n+1 + 1;
	indices[m++] = n+1 + 0;

	indices[m++] = n+1 + 0; // zero after bottom circle
	indices[m++] = 1+0+0; // zero before ring

	for (int a=0; a < n; a++) {
		indices[m++] = 1+a+0;
		indices[m++] = n+1 + 1+a+0;
	}
	indices[m++] = 1+0+0;
	indices[m++] = n+1 + 1+0+0;

	return [super initWithMode:GL_TRIANGLE_STRIP vertices:(GLfloat *) vertices vertexCount:sizeof(vertices) / sizeof(Vertex) indices:indices indexCount:sizeof(indices) / sizeof(GLushort) vertexSize:3 texCoordsSize:2 normalSize:3 tangentSize:3 colorSize:0 isDynamic:NO];
}

@end