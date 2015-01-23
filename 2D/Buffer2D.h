//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


typedef struct {
	GLfloat position[3];
	GLfloat texcoords[2];
} Buffer2DVertex;

static inline Buffer2DVertex Buffer2DVertexMake(GLfloat x, GLfloat y, GLfloat s, GLfloat t) {
	Buffer2DVertex vertex = { x, y, 0, s, t };
	return vertex;
}

typedef struct {
	Buffer2DVertex vertices[6];
} Buffer2DRect;

static inline Buffer2DRect Buffer2DRectMake(GLfloat x, GLfloat y, GLfloat width, GLfloat height, GLfloat s, GLfloat t, GLfloat width2, GLfloat height2) {
	Buffer2DRect rectangle = {
		x, y, 0, s, t,
		x+width, y, 0, s+width2, t,
		x+width, y+height, 0, s+width2, t+height2,
		x, y, 0, s, t,
		x+width, y+height, 0, s+width2, t+height2,
		x, y+height, 0, s, t+height2,
	};
	return rectangle;
}


@interface Buffer2D : Buffer3D

@end
