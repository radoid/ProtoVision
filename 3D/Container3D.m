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
	for (Object3D *child in children)
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
	for (Object3D *child in children) {
		child.parent = nil;
		[child recalculate];
	}
	[children removeAllObjects];
}

- (void)recalculate {
	[super recalculate];
	for (Object3D *child in children)
		[child recalculate];
}

- (void)setColor:(Color2D)color {
	[super setColor:color];
	for (Object3D *child in self.children)
		child.color = color;
}

- (void)setColorDark:(Color2D)color {
	[super setColorDark:color];
	for (Object3D *child in self.children)
		child.colorDark = color;
}

- (void)setColorLight:(Color2D)color {
	[super setColorLight:color];
	for (Object3D *child in self.children)
		child.colorLight = color;
}

- (void)drawWithCamera:(Camera3D *)camera light:(Vector3D)direction opacity:(float)opacity {
	for (Object3D *o in children)
		if (o.opacity > 0) {
			if ([o isKindOfClass:[Container3D class]])
				[(Container3D *)o drawWithCamera:camera light:direction opacity:opacity * o.opacity];
			else
				[o drawWithCamera:camera light:direction];
		}
}

- (void)drawWithCamera:(Camera3D *)camera light:(Vector3D)direction {
	[self drawWithCamera:camera light:direction opacity:self.opacity];
}

@end
