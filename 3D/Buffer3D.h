//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"


@interface Buffer3D : NSObject <NSCopying>

@property (nonatomic, readonly) int vertexcount, indexcount, vertexsize, texcoordssize, normalsize, colorsize;

- (id)initWithMode:(GLenum)drawmode vertices:(GLfloat *)vertices vertexCount:(int)vcount indices:(GLushort *)indices indexCount:(int)icount vertexSize:(int)vsize texCoordsSize:(int)tsize normalSize:(int)nsize colorSize:(int)csize isDynamic:(BOOL)dynamic;

- (void)updateVertices:(GLfloat *)vbuffer vertexCount:(int)vcount indices:(GLushort *)ibuffer indexCount:(int)icount;

- (void)setAttribArraysFromProgram:(Program3D *)program;

- (void)setAttribArray:(int)index size:(int)size type:(int)type stride:(int)stride offset:(int)offset;

- (void)draw;

@end
