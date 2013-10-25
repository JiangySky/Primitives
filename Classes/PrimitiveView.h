//
//  PrimitiveView.h
//  PrimitivesDemo
//
//  Created by Jiangy on 11-5-14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Primitives.h"

@class PrimitiveController;


@interface PrimitiveView : UIView {
	PrimitiveController *	ctrl;
	PrimitivesQZ *		primitiveQZ;
}

@property (nonatomic, retain) PrimitivesQZ *		primitiveQZ;

- (void)initWithController:(PrimitiveController *)controller;

- (void)setupView;
- (void)drawInContext:(CGContextRef)context;
- (void)comingsoon:(CGContextRef)context;

@end
