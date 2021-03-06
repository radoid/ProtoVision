//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "ProtoVision.h"
#import "Container2D.h"


@implementation Container2D

@synthesize children;

- (id)init {
	if (self = [super init])
		children = [[NSMutableArray alloc] init];
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	Container2D *copy = (Container2D *) [super copyWithZone:zone];
	for (Mesh2D *child in children)
		[copy add:[child copy]];
	return copy;
}

- (void)add:(Mesh2D *)child {
	[children addObject:child];
	child.parent = self;
	[child recalculate];
}

- (void)remove:(Mesh2D *)child {
	child.parent = nil;
	[child recalculate];
	[children removeObject:child];
}

- (void)removeAll {
	for (Mesh2D *child in children) {
		child.parent = nil;
		[child recalculate];
	}
	[children removeAllObjects];
}

- (void)recalculate {
	[super recalculate];
	for (Mesh2D *child in children)
		[child recalculate];
}

- (void)drawWithCamera:(Camera2D *)camera alpha:(float)alpha {
	for (Mesh2D *o in children)
		if (o.color.alpha > 0) {
			if ([o isKindOfClass:[Container2D class]])
				[(Container2D *)o drawWithCamera:camera alpha:alpha*o.color.alpha];
			else
				[o drawWithCamera:camera];
		}
}

- (void)drawWithCamera:(Camera2D *)camera {
	[self drawWithCamera:camera alpha:1.0];
}
/*
- (id)findButtonAtLocation:(Vector2D)location {
	for (id o in children) {
		if ([o isKindOfClass:[Button2D class]]) {
			Vector2D sublocation = Vector2DMultiply(location, ((Button2D *)o).worldToLocal);
			//NSLog(@"Klik na (%f, %f)", sublocation.x, sublocation.y);
			if (sublocation.x >= 0 && sublocation.x < ((Button2D *)o).width && sublocation.y >= 0 && sublocation.y < ((Button2D *)o).height)
				return o;
		} else if ([o isKindOfClass:[Container2D class]] && ((Container2D *)o).color.alpha > 0) {
			id o2 = [o findButtonAtLocation:location];
			if (o2)
				return o2;
		}
	}
	return nil;
}
*/
@end
