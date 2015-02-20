//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "Container3D.h"


@implementation Container3D

@synthesize children;

- (id)init {
	if ((self = [super init])) {
		children = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	Container3D *copy = [[Container3D allocWithZone:zone] init];
	copy.position = self.position;
	copy.scaleX = self.scaleX;
	copy.scaleY = self.scaleY;
	copy.scaleZ = self.scaleZ;
	copy.rotation = self.rotation;
	for (Mesh3D *child in children)
		[copy add:[child copy]];
	return copy;
}

- (void)add:(Object3D *)child {
	[children addObject:child];
	child.parent = self;
	[child recalculate];
}

- (void)remove:(Object3D *)child {
	child.parent = nil;
	[child recalculate];
	[children removeObject:child];
}

- (void)removeAll {
	for (Mesh3D *child in children) {
		child.parent = nil;
		[child recalculate];
	}
	[children removeAllObjects];
}

- (void)recalculate {
	[super recalculate];
	for (Mesh3D *child in children)
		[child recalculate];
}

- (float)radius {
	float radius = _radius;
	for (Mesh3D *child in children)
		radius = max(radius, Vector3DLength(child.position) + child.radius);
	NSAssert(!isnan(radius), nil);
	return radius * self.scale;
}

- (void)setProgram:(Program3D *)program {
	for (Mesh3D *child in self.children)
		child.program = program;
}

- (void)setColor:(Color2D)color {
	[super setColor:color];
	for (Mesh3D *child in self.children)
		child.color = color;
}

- (void)setColorAmbient:(Color2D)color {
	[super setColorAmbient:color];
	for (Mesh3D *child in self.children)
		child.colorAmbient = color;
}

- (void)drawWithCamera:(Camera3D *)camera light:(Light3D *)light program:(Program3D *)program opacity:(float)opacity {
	for (Mesh3D *o in children)
		if (o.opacity > 0) {
			if ([o isKindOfClass:[Container3D class]])
				[(Container3D *) o drawWithCamera:camera light:light program:program opacity:opacity * o.opacity];
			else
				[o drawWithCamera:camera light:light program:program];
		}
}

- (void)drawWithCamera:(Camera3D *)camera {
	[self drawWithCamera:camera light:nil program:nil opacity:self.opacity];
}

- (void)drawWithCamera:(Camera3D *)camera light:(Light3D *)light {
	[self drawWithCamera:camera light:light program:nil opacity:self.opacity];
}

- (void)drawWithCamera:(Camera3D *)camera light:(Light3D *)light program:(Program3D *)program {
	[self drawWithCamera:camera light:light program:program opacity:self.opacity];
}

@end
