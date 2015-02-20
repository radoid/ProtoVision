//
// Created by Ante on 15/02/2015.
// Copyright (c) 2015 Radoid. All rights reserved.
//

#import "ProtoVision.h"


@interface FrameBuffer3D : NSObject

@property (readonly) GLuint name, texture;
@property (readonly) int width, height;

- (id)initWithWidth:(int)width height:(int)height;

- (void)bind;

- (void)unbind;

@end