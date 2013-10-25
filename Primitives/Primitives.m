//
//  DrawPrimitives.m
//  DrawPrimitivesDemo
//
//  Created by Jiangy on 11-4-26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Primitives.h"


@implementation Primitives

#pragma mark -

+ (CGFloat)angleBetweenPoint:(CGPoint)startPoint andPoint:(CGPoint)endPoint {
	CGFloat dw = endPoint.x - startPoint.x;
	CGFloat dh = endPoint.y - startPoint.y;
	CGFloat angle;
	if (dw == 0) {
		if (dh > 0) {
			angle = 90;
		} else if (dh < 0) {
			angle = 270;
		} else {
			angle = 0;
		}
	} else {
		float randians = atan(dh / dw);
		angle = RADIANS_TO_DEGREES(randians);
		angle += (dw < 0 ? 180 : 0);
		angle += (dh < 0 ? 360 : 0);
	}
	
	return (int)angle % 360;
}

+ (CGPoint)centerOfArcFrom:(CGPoint)startPoint to:(CGPoint)endPoint withRadius:(CGFloat)radius clockwise:(kDrawStyle)clockwise {
	CGFloat dis = DISTANCE_BETWEEN_POINT(startPoint, endPoint);
	radius = MAX(radius, dis / 2);
	CGPoint center = CGPointMake((startPoint.x + endPoint.x) / 2, (startPoint.y + endPoint.y) / 2);
	CGFloat h = sqrtf(powf(radius, 2) - powf(dis / 2, 2));
	CGFloat k, xd, yd, x, y;
	if (startPoint.x == endPoint.x) {
		xd = h;
		yd = 0;
	} else if (startPoint.y == endPoint.y) {
		xd = 0;
		yd = -h;
	} else {
		k = (startPoint.y - endPoint.y) / (startPoint.x - endPoint.x);
		xd = sqrtf(powf(h, 2) * powf(k, 2) / (powf(k, 2) + 1));
		yd = -xd / k;
	}

	if ((startPoint.x > endPoint.x && clockwise == kArcCounterClockwise) 
		|| (startPoint.x < endPoint.x && clockwise == kArcClockwise)
		|| (startPoint.x == endPoint.x && startPoint.y > endPoint.y && clockwise == kArcCounterClockwise)
		|| (startPoint.x == endPoint.x && startPoint.y < endPoint.y && clockwise == kArcClockwise)) {
		x = center.x - xd;
		y = center.y - yd;
	} else {
		x = center.x + xd;
		y = center.y + yd;
	}
	center = CGPointMake(x, y);
	
	return center;
}

+ (UIImage *)glToImage {
    NSInteger myDataLength = 320 * 480 * 4;
    
    // allocate array and read pixels into it.
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    glReadPixels(0, 0, 320, 480, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    
    // gl renders "upside down" so swap top to bottom into new array.
    // there's gotta be a better way, but this works.
    GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
    for(int y = 0; y <480; y++)
    {
        for(int x = 0; x <320 * 4; x++)
        {
            buffer2[(479 - y) * 320 * 4 + x] = buffer[y * 4 * 320 + x];
        }
    }
    free(buffer);
    // make data provider with data.
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);
    
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * 320;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(320, 480, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    // then make the uiimage from that
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    return myImage;
}

@end


#pragma mark -
#pragma mark === Draw Primitives use Quartz ===
#pragma mark -

@implementation PrimitivesQZ

#pragma mark -

- (void)cleanScreenInContext:(CGContextRef)context {
	[self cleanScreenInContext:context withColor:DEFAULT_COLOR];
}

- (void)cleanScreenInContext:(CGContextRef)context withColor:(UIColor *)color {
	[self cleanRect:CGContextGetClipBoundingBox(context) inContext:context withColor:color];
}

- (void)cleanRect:(CGRect)rect inContext:(CGContextRef)context withColor:(UIColor *)color {
	SET_CONTEXT_WITH_COLOR(context, color);
	CGContextFillRect(context, rect);
}

#pragma mark -

- (void)drawPoint:(CGPoint)point inContext:(CGContextRef)context withColor:(UIColor *)color {
	[self drawPoint:point inContext:context withColor:color width:MAX(1.8, DEFAULT_LINE_WIDTH)];
}

- (void)drawPoint:(CGPoint)point inContext:(CGContextRef)context withColor:(UIColor *)color width:(CGFloat)width {
	width = MAX(1.8, width);
	CGRect rect = CGRectMake(point.x - width / 2, point.y - width / 2, width, width);
	[self fillEllipse:rect inContext:context withColor:color];
}

#pragma mark -

- (void)drawLineFrom:(CGPoint)startPoint to:(CGPoint)endPoint inContext:(CGContextRef)context withColor:(UIColor *)color {
	[self drawLineFrom:startPoint to:endPoint 
			 inContext:context 
			 withColor:color width:DEFAULT_LINE_WIDTH cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN 
		 solidOrDotted:kLineSolid];
}

- (void)drawLineFrom:(CGPoint)startPoint to:(CGPoint)endPoint 
		   inContext:(CGContextRef)context 
		   withColor:(UIColor *)color width:(CGFloat)width 
	   solidOrDotted:(kDrawStyle)isDotted {	
	
	[self drawLineFrom:startPoint to:endPoint 
			 inContext:context 
			 withColor:color width:width cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN 
		 solidOrDotted:isDotted];
}

- (void)drawLineFrom:(CGPoint)startPoint to:(CGPoint)endPoint 
		   inContext:(CGContextRef)context 
		   withColor:(UIColor *)color width:(CGFloat)width cap:(CGLineCap)cap join:(CGLineJoin)join 
	   solidOrDotted:(kDrawStyle)isDotted {
	
	CGContextMoveToPoint(context, startPoint.x, startPoint.y);
	CGContextAddLineToPoint(context, endPoint.x, endPoint.y);	
	
	CONTEXT_DRAW_WITH_ARGS(context, color, width, cap, join, isDotted);
}

- (void)drawLines:(CGPoint *)points pointAmount:(NSInteger)count inContext:(CGContextRef)context withColor:(UIColor *)color {
	[self drawLines:points pointAmount:count 
		  inContext:context 
		  withColor:color width:DEFAULT_LINE_WIDTH cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN 
	  solidOrDotted:kLineSolid 
		  joinOrSeg:kLineJoin];
}

- (void)drawLines:(CGPoint *)points pointAmount:(NSInteger)count 
		inContext:(CGContextRef)context 
		withColor:(UIColor *)color width:(CGFloat)width 
	solidOrDotted:(kDrawStyle)isDotted 
		joinOrSeg:(kDrawStyle)isSeg {
	
	[self drawLines:points pointAmount:count 
		  inContext:context 
		  withColor:color width:width cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN 
	  solidOrDotted:isDotted 
		  joinOrSeg:isSeg];
}

- (void)drawLines:(CGPoint *)points pointAmount:(NSInteger)count 
		inContext:(CGContextRef)context 
		withColor:(UIColor *)color width:(CGFloat)width cap:(CGLineCap)cap join:(CGLineJoin)join 
	solidOrDotted:(kDrawStyle)isDotted 
		joinOrSeg:(kDrawStyle)isSeg {
	
	if (count <= 0) {
		LOG_INFO(@"draw line without any point", self);
		return;
	}
	
	if (count == 1) {
		[self drawPoint:points[0] inContext:context withColor:color width:width];
		
	} else {
		if (isSeg) {
			CGContextSaveGState(context);
			SET_CONTEXT_WITH_ARGS(context, color, color, width, cap, join);
			SET_CONTEXT_LINE_STYPE(context, isDotted);
			CGContextStrokeLineSegments(context, points, count);
			CGContextRestoreGState(context);
			
		} else {
			CGContextAddLines(context, points, count);
			CONTEXT_DRAW_WITH_ARGS(context, color, width, cap, join, isDotted);
		}		
		
	}
}

- (void)drawLinesInContext:(CGContextRef)context withColor:(UIColor *)color sPoints:(NSString *)s_point, ... {	
	if (!s_point) {
		LOG_INFO(@"draw line without any point", self);
		return;
	}
	
	CGPoint tempPoint;
	if (s_point) {
		tempPoint = pString(s_point);
		CGContextMoveToPoint(context, tempPoint.x, tempPoint.y);
	} else {
		return;
	}
	
	NSInteger count = 0;
	NSString * tempPointStr = s_point;
	va_list params;
	va_start(params, s_point);
	while (tempPointStr) {
		tempPoint = pString(tempPointStr);
		CGContextAddLineToPoint(context, tempPoint.x, tempPoint.y);	
		count++;
		tempPointStr = va_arg(params, NSString *);
	}
	va_end(params);
	
	if (count == 1) {
		[self drawPoint:pString(s_point) inContext:context withColor:color width:DEFAULT_LINE_WIDTH];
		
	} else if (count > 1) {
		CONTEXT_DRAW_WITH_ARGS(context, color, 1, DEFAULT_LINE_CAP, DEFAULT_LINE_JOIN, kLineSolid);
	} 
}

- (void)drawLinesInContext:(CGContextRef)context 
				 withColor:(UIColor *)color width:(CGFloat)width
			 solidOrDotted:(kDrawStyle)isDotted 
				 joinOrSeg:(kDrawStyle)isSeg  
				   sPoints:(NSString *)s_point, ... {
	
	if (!s_point) {
		LOG_INFO(@"draw line without any point", self);
		return;
	}
	
	CGPoint tempPoint;
	if (s_point) {
		tempPoint = pString(s_point);
		CGContextMoveToPoint(context, tempPoint.x, tempPoint.y);
	} else {
		return;
	}
	
	NSInteger count = 0;
	NSString * tempPointStr = s_point;
	va_list params;
	va_start(params, s_point);
	while (tempPointStr) {
		tempPoint = pString(tempPointStr);
		if (isSeg && count % 2 == 0) {
			CGContextMoveToPoint(context, tempPoint.x, tempPoint.y);
		} else {
			CGContextAddLineToPoint(context, tempPoint.x, tempPoint.y);	
		}
		count++;
		tempPointStr = va_arg(params, NSString *);
	}
	va_end(params);
	
	if (count == 1) {
		[self drawPoint:pString(s_point) inContext:context withColor:color width:width];
		
	} else if (count > 1) {
		CONTEXT_DRAW_WITH_ARGS(context, color, width, DEFAULT_LINE_CAP, DEFAULT_LINE_JOIN, isDotted);
	} 
}

- (void)drawLinesInContext:(CGContextRef)context 
				 withColor:(UIColor *)color width:(CGFloat)width cap:(CGLineCap)cap join:(CGLineJoin)join 
			 solidOrDotted:(kDrawStyle)isDotted 
				 joinOrSeg:(kDrawStyle)isSeg  
				   sPoints:(NSString *)s_point, ... {
	
	if (!s_point) {
		LOG_INFO(@"draw line without any point", self);
		return;
	}
	
	CGPoint tempPoint;
	if (s_point) {
		tempPoint = pString(s_point);
		CGContextMoveToPoint(context, tempPoint.x, tempPoint.y);
	} else {
		return;
	}
	
	NSInteger count = 0;
	NSString * tempSPoint = s_point;
	va_list params;
	va_start(params, s_point);
	while (tempSPoint) {
		tempPoint = pString(tempSPoint);
		if (isSeg && count % 2 == 0) {
			CGContextMoveToPoint(context, tempPoint.x, tempPoint.y);
		} else {
			CGContextAddLineToPoint(context, tempPoint.x, tempPoint.y);	
		}
		count++;
		tempSPoint = va_arg(params, NSString *);
	}
	va_end(params);
	
	if (count == 1) {
		[self drawPoint:pString(s_point) inContext:context withColor:color width:width];
		
	} else if (count > 1) {
		CONTEXT_DRAW_WITH_ARGS(context, color, width, cap, join, isDotted);
	} 
}

#pragma mark -

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context withColor:(UIColor *)color {
	[self drawRect:rect inContext:context withColor:color width:DEFAULT_LINE_WIDTH solidOrDotted:kLineSolid];
}

- (void)drawRect:(CGRect)rect 
	   inContext:(CGContextRef)context 
	   withColor:(UIColor *)color width:(CGFloat)width 
   solidOrDotted:(kDrawStyle)isDotted {
	
	CGContextAddRect(context, rect);	
	CONTEXT_DRAW_WITH_ARGS(context, color, width, DEFAULT_LINE_CAP, DEFAULT_LINE_JOIN, isDotted);
}

- (void)fillRect:(CGRect)rect inContext:(CGContextRef)context withColor:(UIColor *)color {
	CGContextSaveGState(context);
	SET_CONTEXT_WITH_COLOR(context, color);
	CGContextFillRect(context, rect);
	CGContextRestoreGState(context);
}

- (void)drawRects:(CGRect *)rects rectAmount:(NSInteger)count inContext:(CGContextRef)context withColor:(UIColor *)color {
	[self drawRects:rects rectAmount:count 
		  inContext:context 
		  withColor:color width:DEFAULT_LINE_WIDTH 
	  solidOrDotted:kLineSolid];
}

- (void)drawRects:(CGRect *)rects rectAmount:(NSInteger)count 
		inContext:(CGContextRef)context 
		withColor:(UIColor *)color width:(CGFloat)width 
	solidOrDotted:(kDrawStyle)isDotted {
	
	if (count <= 0) {
		LOG_INFO(@"draw rectangle without any rect", self);
		return;
	}
	
	CGContextAddRects(context, rects, count);	
	CONTEXT_DRAW_WITH_ARGS(context, color, width, DEFAULT_LINE_CAP, DEFAULT_LINE_JOIN, isDotted);
}

- (void)fillRects:(CGRect *)rects rectAmount:(NSInteger)count 
		inContext:(CGContextRef)context withColor:(UIColor *)color {
	
	if (count <= 0) {
		LOG_INFO(@"fill rectangle without any rect", self);
		return;
	}
	
	CGContextSaveGState(context);
	SET_CONTEXT_WITH_COLOR(context, color);	
	CGContextFillRects(context, rects, count);
	CGContextRestoreGState(context);
}

- (void)drawRectsInContext:(CGContextRef)context withColor:(UIColor *)color sRects:(NSString *)simgRect, ... {
	
	if (!simgRect) {
		LOG_INFO(@"draw rectangle without any rect", self);
		return;
	}
	
	CGRect rect = CGRectZero;
	NSString * tempSRect = simgRect;
	va_list(params);
	va_start(params, simgRect);
	while (tempSRect) {
		rect = rString(tempSRect);
		CGContextAddRect(context, rect);
		tempSRect = va_arg(params, NSString *);
	}
	va_end(params);
	
	CONTEXT_DRAW_WITH_ARGS(context, color, 1, DEFAULT_LINE_CAP, DEFAULT_LINE_JOIN, kLineSolid);
}

- (void)drawRectsInContext:(CGContextRef)context 
				 withColor:(UIColor *)color width:(CGFloat)width 
			 solidOrDotted:(kDrawStyle)isDotted 
					sRects:(NSString *)simgRect, ... {
	
	if (!simgRect) {
		LOG_INFO(@"draw rectangle without any rect", self);
		return;
	}
	
	CGRect rect = CGRectZero;
	NSString * tempSRect = simgRect;
	va_list(params);
	va_start(params, simgRect);
	while (tempSRect) {
		rect = rString(tempSRect);
		CGContextAddRect(context, rect);
		tempSRect = va_arg(params, NSString *);
	}
	va_end(params);
	
	CONTEXT_DRAW_WITH_ARGS(context, color, width, DEFAULT_LINE_CAP, DEFAULT_LINE_JOIN, isDotted);
}

- (void)fillRectsInContext:(CGContextRef)context 
				 withColor:(UIColor *)color 
					sRects:(NSString *)simgRect, ... {
	
	if (!simgRect) {
		LOG_INFO(@"fill rectangle without any rect", self);
		return;
	}
	
	CGRect rect = CGRectZero;
	NSString * tempSRect = simgRect;
	va_list(params);
	va_start(params, simgRect);
	while (tempSRect) {
		rect = rString(tempSRect);
		CGContextAddRect(context, rect);
		tempSRect = va_arg(params, NSString *);
	}
	va_end(params);
	
	CGContextSaveGState(context);
	SET_CONTEXT_WITH_COLOR(context, color);
	CONTEXT_FILL(context);
	CGContextRestoreGState(context);
}

#pragma mark -

- (void)drawEllipse:(CGRect)rect inContext:(CGContextRef)context withColor:(UIColor *)color {
	[self drawEllipse:rect inContext:context withColor:color width:DEFAULT_LINE_WIDTH solidOrDotted:kLineSolid];
}

- (void)drawEllipse:(CGRect)rect 
		  inContext:(CGContextRef)context 
		  withColor:(UIColor *)color width:(CGFloat)width 
	  solidOrDotted:(kDrawStyle)isDotted {
	
	CGContextAddEllipseInRect(context, rect);	
	CONTEXT_DRAW_WITH_ARGS(context, color, width, DEFAULT_LINE_CAP, DEFAULT_LINE_JOIN, isDotted);
}

- (void)fillEllipse:(CGRect)rect inContext:(CGContextRef)context withColor:(UIColor *)color {
	CGContextSaveGState(context);
	SET_CONTEXT_WITH_COLOR(context, color);	
	CGContextFillEllipseInRect(context, rect);	
	CGContextRestoreGState(context);
}

- (void)drawEllipses:(CGRect *)rects rectAmount:(NSInteger)count inContext:(CGContextRef)context withColor:(UIColor *)color {
	[self drawEllipses:rects rectAmount:count 
			 inContext:context 
			 withColor:color width:DEFAULT_LINE_WIDTH 
		 solidOrDotted:kLineSolid];
}

- (void)drawEllipses:(CGRect *)rects rectAmount:(NSInteger)count 
		   inContext:(CGContextRef)context 
		   withColor:(UIColor *)color width:(CGFloat)width 
	   solidOrDotted:(kDrawStyle)isDotted {
	
	if (count <= 0) {
		LOG_INFO(@"draw ellipse without any rect", self);
		return;
	}
	
	for (int i = 0; i < count; i++) {
		CGContextAddEllipseInRect(context, rects[i]);
	}
	CONTEXT_DRAW_WITH_ARGS(context, color, width, DEFAULT_LINE_CAP, DEFAULT_LINE_JOIN, isDotted);
}

- (void)fillEllipses:(CGRect *)rects rectAmount:(NSInteger)count 
		   inContext:(CGContextRef)context 
		   withColor:(UIColor *)color {
	
	if (count <= 0) {
		LOG_INFO(@"fill ellipse without any rect", self);
		return;
	}
	
	CGContextSaveGState(context);
	SET_CONTEXT_WITH_COLOR(context, color);
	for (int i = 0; i < count; i++) {
		CGContextFillEllipseInRect(context, rects[i]);
	}
	CGContextRestoreGState(context);
}

- (void)drawEllipsesInContext:(CGContextRef)context withColor:(UIColor *)color sRects:(NSString *)simgRect, ... {
	
	if (!simgRect) {
		LOG_INFO(@"draw ellipse without any rect", self);
		return;
	}
	
	NSString * tempSRect = simgRect;
	va_list(params);
	va_start(params, simgRect);
	while (tempSRect) {
		CGContextAddEllipseInRect(context, rString(tempSRect));
		tempSRect = va_arg(params, NSString *);
	}
	va_end(params);
	CONTEXT_DRAW_WITH_ARGS(context, color, 1, DEFAULT_LINE_CAP, DEFAULT_LINE_JOIN, kLineSolid);
}

- (void)drawEllipsesInContext:(CGContextRef)context 
					withColor:(UIColor *)color width:(CGFloat)width 
				solidOrDotted:(kDrawStyle)isDotted 
					   sRects:(NSString *)simgRect, ... {
	
	if (!simgRect) {
		LOG_INFO(@"draw ellipse without any rect", self);
		return;
	}
	
	NSString * tempSRect = simgRect;
	va_list(params);
	va_start(params, simgRect);
	while (tempSRect) {
		CGContextAddEllipseInRect(context, rString(tempSRect));
		tempSRect = va_arg(params, NSString *);
	}
	va_end(params);
	CONTEXT_DRAW_WITH_ARGS(context, color, width, DEFAULT_LINE_CAP, DEFAULT_LINE_JOIN, isDotted);
}

- (void)fillEllipsesInContext:(CGContextRef)context 
					withColor:(UIColor *)color 
					   sRects:(NSString *)simgRect, ... {
	
	if (!simgRect) {
		LOG_INFO(@"fill ellipse without any rect", self);
		return;
	}
	
	CGContextSaveGState(context);
	SET_CONTEXT_WITH_COLOR(context, color);
	NSString * tempSRect = simgRect;
	va_list(params);
	va_start(params, simgRect);
	while (tempSRect) {
		CGContextFillEllipseInRect(context, rString(tempSRect));
		tempSRect = va_arg(params, NSString *);
	}
	va_end(params);
	CGContextRestoreGState(context);
}

#pragma mark -

- (void)drawArcAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise 
		inContext:(CGContextRef)context
		withColor:(UIColor *)color {
	
	[self drawArcAt:center radius:radius 
			   from:startAngle to:endAngle clockwise:clockwise 
		  inContext:context 
		  withColor:color width:DEFAULT_LINE_WIDTH cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN 
	  solidOrDotted:kLineSolid];
}

- (void)drawArcAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise
		inContext:(CGContextRef)context 
		withColor:(UIColor *)color width:(CGFloat)width 
	solidOrDotted:(kDrawStyle)isDotted {
	
	[self drawArcAt:center radius:radius from:startAngle to:endAngle clockwise:clockwise 
		  inContext:context 
		  withColor:color width:width cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN
	  solidOrDotted:isDotted];
}

- (void)drawArcAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise
		inContext:(CGContextRef)context 
		withColor:(UIColor *)color width:(CGFloat)width cap:(CGLineCap)cap join:(CGLineJoin)join 
	solidOrDotted:(kDrawStyle)isDotted {
	
	CGContextAddArc(context, center.x, center.y, radius, DEGREES_TO_RADIANS(startAngle), DEGREES_TO_RADIANS(endAngle), clockwise);
	CONTEXT_DRAW_WITH_ARGS(context, color, width, cap, join, isDotted);
}

- (void)fillArcAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise
		inContext:(CGContextRef)context
		withColor:(UIColor *)color {
	
	CGContextSaveGState(context);
	CGContextAddArc(context, center.x, center.y, radius, DEGREES_TO_RADIANS(startAngle), DEGREES_TO_RADIANS(endAngle), clockwise);
	SET_CONTEXT_WITH_COLOR(context, color);
	CONTEXT_FILL(context);
	CGContextRestoreGState(context);
}

- (void)drawArcFrom:(CGPoint)startPoint to:(CGPoint)endPoint radius:(CGFloat)radius clockwise:(kDrawStyle)clockwise 
		  inContext:(CGContextRef)context 
		  withColor:(UIColor *)color {
	
	[self drawArcFrom:startPoint to:endPoint radius:radius clockwise:clockwise 
			inContext:context
			withColor:color width:DEFAULT_LINE_WIDTH cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN 
		solidOrDotted:kLineSolid];
}

- (void)drawArcFrom:(CGPoint)startPoint to:(CGPoint)endPoint radius:(CGFloat)radius clockwise:(kDrawStyle)clockwise 
		  inContext:(CGContextRef)context 
		  withColor:(UIColor *)color width:(CGFloat)width 
	  solidOrDotted:(kDrawStyle)isDotted {
	
	[self drawArcFrom:startPoint to:endPoint radius:radius clockwise:clockwise 
			inContext:context 
			withColor:color width:width cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN 
		solidOrDotted:isDotted];
}

- (void)drawArcFrom:(CGPoint)startPoint to:(CGPoint)endPoint radius:(CGFloat)radius clockwise:(kDrawStyle)clockwise 
		  inContext:(CGContextRef)context 
		  withColor:(UIColor *)color width:(CGFloat)width cap:(CGLineCap)cap join:(CGLineJoin)join 
	  solidOrDotted:(kDrawStyle)isDotted {
	
	if (CGPointEqualToPoint(startPoint, endPoint)) {
		[self drawPoint:startPoint inContext:context withColor:color width:width];
		
	} else {
		radius = MAX(radius, DISTANCE_BETWEEN_POINT(startPoint, endPoint) / 2);
		CGPoint center = [Primitives centerOfArcFrom:startPoint to:endPoint withRadius:radius clockwise:clockwise];
		CGFloat startAngle = [Primitives angleBetweenPoint:center andPoint:startPoint];
		CGFloat endAngle = [Primitives angleBetweenPoint:center andPoint:endPoint];
		[self drawArcAt:center radius:radius 
				   from:startAngle to:endAngle clockwise:clockwise 
			  inContext:context 
			  withColor:color width:width cap:cap join:join 
		  solidOrDotted:isDotted];		
	}	
}

- (void)fillArcFrom:(CGPoint)startPoint to:(CGPoint)endPoint radius:(CGFloat)radius clockwise:(kDrawStyle)clockwise 
		  inContext:(CGContextRef)context 
		  withColor:(UIColor *)color {
	
	if (CGPointEqualToPoint(startPoint, endPoint)) {
		[self drawPoint:startPoint inContext:context withColor:color width:DEFAULT_LINE_WIDTH];
		
	} else {
		radius = MAX(radius, DISTANCE_BETWEEN_POINT(startPoint, endPoint) / 2);
		CGPoint center = [Primitives centerOfArcFrom:startPoint to:endPoint withRadius:radius clockwise:clockwise];
		CGFloat startAngle = [Primitives angleBetweenPoint:center andPoint:startPoint];
		CGFloat endAngle = [Primitives angleBetweenPoint:center andPoint:endPoint];
		[self fillArcAt:center radius:radius 
				   from:startAngle to:endAngle clockwise:clockwise 
			  inContext:context 
			  withColor:color];		
	}
}

#pragma mark -

- (void)drawBezierCurve:(kBezier)bPoints inContext:(CGContextRef)context withColor:(UIColor *)color {
	
	[self drawBezierCurve:bPoints 
				inContext:context 
				withColor:color width:DEFAULT_LINE_WIDTH cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN 
			solidOrDotted:kLineSolid];
}

- (void)drawBezierCurve:(kBezier)bPoints 
			  inContext:(CGContextRef)context 
			  withColor:(UIColor *)color width:(CGFloat)width 
		  solidOrDotted:(kDrawStyle)isDotted {
	
	[self drawBezierCurve:bPoints 
				inContext:context 
				withColor:color width:width cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN 
			solidOrDotted:isDotted];	
}

- (void)drawBezierCurve:(kBezier)bPoints 
			  inContext:(CGContextRef)context 
			  withColor:(UIColor *)color width:(CGFloat)width cap:(CGLineCap)cap join:(CGLineJoin)join
		  solidOrDotted:(kDrawStyle)isDotted {
	
	if (CGPointEqualToPoint(bPoints.sp, bPoints.ep)) {
		[self drawPoint:bPoints.sp inContext:context withColor:color width:width];
		
	} else {
		CGContextMoveToPoint(context, bPoints.sp.x, bPoints.sp.y);
		if (CGPointEqualToPoint(bPoints.cp1, bPoints.cp2)) {
			CGContextAddQuadCurveToPoint(context, bPoints.cp1.x, bPoints.cp1.y, bPoints.ep.x, bPoints.ep.y);
		} else {
			CGContextAddCurveToPoint(context, bPoints.cp1.x, bPoints.cp1.y, bPoints.cp2.x, bPoints.cp2.y, bPoints.ep.x, bPoints.ep.y);
		}
		CONTEXT_DRAW_WITH_ARGS(context, color, width, cap, join, isDotted);
	}
}

#pragma mark -

- (void)addRoundRect:(CGRect)rect radius:(CGFloat)radius toContext:(CGContextRef)context {
	CGFloat minX = CGRectGetMinX(rect), midX = CGRectGetMidX(rect), maxX = CGRectGetMaxX(rect);
	CGFloat minY = CGRectGetMinY(rect), midY = CGRectGetMidY(rect), maxY = CGRectGetMaxY(rect);
	
	CGContextMoveToPoint(context, minX, midY);
	CGContextAddArcToPoint(context, minX, minY, midX, minY, radius);
	CGContextAddArcToPoint(context, maxX, minY, maxX, midY, radius);
	CGContextAddArcToPoint(context, maxX, maxY, midX, maxY, radius);
	CGContextAddArcToPoint(context, minX, maxY, minX, midY, radius);
	CGContextClosePath(context);
}

- (void)drawRoundRect:(CGRect)rect radius:(CGFloat)radius inContext:(CGContextRef)context withColor:(UIColor *)color {
	[self drawRoundRect:rect radius:radius inContext:context withColor:color width:DEFAULT_LINE_WIDTH solidOrDotted:kLineSolid];
}

- (void)drawRoundRect:(CGRect)rect radius:(CGFloat)radius 
			inContext:(CGContextRef)context 
			withColor:(UIColor *)color width:(CGFloat)width 
		solidOrDotted:(kDrawStyle)isDotted {
	
	[self addRoundRect:rect radius:radius toContext:context];
	CONTEXT_DRAW_WITH_ARGS(context, color, width, DEFAULT_LINE_CAP, DEFAULT_LINE_JOIN, isDotted);
}

- (void)fillRoundRect:(CGRect)rect radius:(CGFloat)radius inContext:(CGContextRef)context withColor:(UIColor *)color {
	CGContextSaveGState(context);
	[self addRoundRect:rect radius:radius toContext:context];
	SET_CONTEXT_WITH_COLOR(context, color);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGContextRestoreGState(context);
}

#pragma mark -

- (void)addPolygonByPoints:(CGPoint *)points pointAmount:(NSInteger)count toContext:(CGContextRef)context {
	CGContextMoveToPoint(context, points[0].x, points[0].y);
	CGContextAddLines(context, points, count);
	CGContextClosePath(context);
}

- (void)drawPolygonByPoints:(CGPoint *)points pointAmount:(NSInteger)count 
				  inContext:(CGContextRef)context 
				  withColor:(UIColor *)color {
	
	[self drawPolygonByPoints:points pointAmount:count inContext:context 
					withColor:color width:DEFAULT_LINE_WIDTH cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN 
				solidOrDotted:kLineSolid];
}

- (void)drawPolygonByPoints:(CGPoint *)points pointAmount:(NSInteger)count 
				  inContext:(CGContextRef)context 
				  withColor:(UIColor *)color width:(CGFloat)width 
			  solidOrDotted:(kDrawStyle)isDotted {	
	
	[self drawPolygonByPoints:points pointAmount:count 
					inContext:context 
					withColor:color width:width cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN 
				solidOrDotted:isDotted];
}

- (void)drawPolygonByPoints:(CGPoint *)points pointAmount:(NSInteger)count 
				  inContext:(CGContextRef)context
				  withColor:(UIColor *)color width:(CGFloat)width cap:(CGLineCap)cap join:(CGLineJoin)join 
			  solidOrDotted:(kDrawStyle)isDotted {
	
	if (count < 3) {
		LOG_INFO(@"draw polygon with less than 3 points", self);
		return;
	}
	
	[self addPolygonByPoints:points pointAmount:count toContext:context];
	CONTEXT_DRAW_WITH_ARGS(context, color, width, cap, join, isDotted);
}

- (void)fillPolygonByPoints:(CGPoint *)points pointAmount:(NSInteger)count 
				  inContext:(CGContextRef)context 
				  withColor:(UIColor *)color {
	
	[self fillPolygonByPoints:points pointAmount:count 
					inContext:context 
					withColor:color fillColor:color width:DEFAULT_LINE_WIDTH cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN 
				solidOrDotted:kLineSolid
					 pathMode:kCGPathFill];
}

- (void)fillPolygonByPoints:(CGPoint *)points pointAmount:(NSInteger)count 
				  inContext:(CGContextRef)context 
				  withColor:(UIColor *)sColor fillColor:(UIColor *)fColor width:(CGFloat)width 
						cap:(CGLineCap)cap join:(CGLineJoin)join 
			  solidOrDotted:(kDrawStyle)isDotted 
				   pathMode:(CGPathDrawingMode)mode {
	
	if (count < 3) {
		LOG_INFO(@"draw polygon with less than 3 points", self);
		return;
	}
	CGContextSaveGState(context);
	[self addPolygonByPoints:points pointAmount:count toContext:context];
	SET_CONTEXT_WITH_ARGS(context, sColor, fColor, width, cap, join);
	SET_CONTEXT_LINE_STYPE(context, isDotted);
	CGContextDrawPath(context, mode);	
	CGContextRestoreGState(context);
}

- (void)addReularPolygon:(NSInteger)sideAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
			   toContext:(CGContextRef)context {
	CGFloat radians = DEGREES_TO_RADIANS(angle);
	CGFloat x = center.x - radius * sin(radians);
	CGFloat y = center.y - radius * cos(radians);
	CGContextMoveToPoint(context, x, y);
	for (int i = 1; i < sideAmount; i++) {
		radians += 2 * M_PI / sideAmount;
		x = center.x - radius * sin(radians);
		y = center.y - radius * cos(radians);
		CGContextAddLineToPoint(context, x, y);
	}
	CGContextClosePath(context);
}

- (void)drawRegularPolygon:(NSInteger)sideAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
				 inContext:(CGContextRef)context 
				 withColor:(UIColor *)color {
	
	[self drawRegularPolygon:sideAmount at:center radius:radius angle:angle
				   inContext:context 
				   withColor:color width:DEFAULT_LINE_WIDTH cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN 
			   solidOrDotted:kLineSolid];
}

- (void)drawRegularPolygon:(NSInteger)sideAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
				 inContext:(CGContextRef)context 
				 withColor:(UIColor *)color width:(CGFloat)width 
			 solidOrDotted:(kDrawStyle)isDotted {
	
	[self drawRegularPolygon:sideAmount at:center radius:radius angle:angle
				   inContext:context 
				   withColor:color width:width cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN 
			   solidOrDotted:isDotted];
}

- (void)drawRegularPolygon:(NSInteger)sideAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
				 inContext:(CGContextRef)context 
				 withColor:(UIColor *)color width:(CGFloat)width cap:(CGLineCap)cap join:(CGLineJoin)join 
			 solidOrDotted:(kDrawStyle)isDotted {
	
	if (sideAmount < 3) {
		LOG_INFO(@"draw regular polygon with less than 3 sides", self);
		return;
	}
	
	[self addReularPolygon:sideAmount at:center radius:radius angle:angle toContext:context];
	CONTEXT_DRAW_WITH_ARGS(context, color, width, cap, join, isDotted);
}

- (void)fillRegularPolygon:(NSInteger)sideAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
				 inContext:(CGContextRef)context 
				 withColor:(UIColor *)color {
	
	[self fillRegularPolygon:sideAmount at:center radius:radius angle:angle 
				   inContext:context 
				   withColor:color fillColor:color width:DEFAULT_LINE_WIDTH cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN 
			   solidOrDotted:kLineSolid 
					pathMode:kCGPathFill];
}

- (void)fillRegularPolygon:(NSInteger)sideAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
				 inContext:(CGContextRef)context 
				 withColor:(UIColor *)color 
			 solidOrDotted:(kDrawStyle)isDotted 
				  pathMode:(CGPathDrawingMode)mode {
	
	[self fillRegularPolygon:sideAmount at:center radius:radius angle:angle 
				   inContext:context 
				   withColor:color fillColor:color width:DEFAULT_LINE_WIDTH cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN 
			   solidOrDotted:isDotted 
					pathMode:mode];
}

- (void)fillRegularPolygon:(NSInteger)sideAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
				 inContext:(CGContextRef)context 
				 withColor:(UIColor *)sColor fillColor:(UIColor *)fColor width:(CGFloat)width cap:(CGLineCap)cap join:(CGLineJoin)join 
			 solidOrDotted:(kDrawStyle)isDotted 
				  pathMode:(CGPathDrawingMode)mode {
	
	if (sideAmount < 3) {
		LOG_INFO(@"draw regular polygon with less than 3 sides", self);
		return;
	}
	
	[self addReularPolygon:sideAmount at:center radius:radius angle:angle toContext:context];
	CGContextSaveGState(context);
	SET_CONTEXT_WITH_ARGS(context, sColor, fColor, width, cap, join);
	SET_CONTEXT_LINE_STYPE(context, isDotted);
	CGContextDrawPath(context, mode);
	CGContextRestoreGState(context);
}

#pragma mark -

- (void)addStar:(NSInteger)pointAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
	  toContext:(CGContextRef)context {
	if (pointAmount % 2 == 0) {
		if (pointAmount == 4) {
			[self addReularPolygon:pointAmount at:center radius:radius angle:angle toContext:context];
		} else {
			[self addStar:(pointAmount / 2) at:center radius:radius angle:angle toContext:context];
			[self addStar:(pointAmount / 2) at:center radius:radius angle:(angle + 360 / pointAmount) toContext:context];
		}
		
	} else {
		CGFloat radians = DEGREES_TO_RADIANS(angle);
		CGFloat x = center.x - radius * sin(radians);
		CGFloat y = center.y - radius * cos(radians);
		CGContextMoveToPoint(context, x, y);
		
		for (int i = 1; i < pointAmount; i++) {
			radians += 2 * 2 * M_PI / pointAmount;
			x = center.x - radius * sin(radians);
			y = center.y - radius * cos(radians);
			CGContextAddLineToPoint(context, x, y);
		}
		CGContextClosePath(context);
	}
}

- (void)drawStar:(NSInteger)pointAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
	   inContext:(CGContextRef)context 
	   withColor:(UIColor *)color {
	
	[self drawStar:pointAmount at:center radius:radius angle:angle 
		 inContext:context 
		 withColor:color width:DEFAULT_LINE_WIDTH cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN 
	 solidOrDotted:kLineSolid];
}

- (void)drawStar:(NSInteger)pointAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
	   inContext:(CGContextRef)context 
	   withColor:(UIColor *)color width:(CGFloat)width 
   solidOrDotted:(kDrawStyle)isDotted {
	
	[self drawStar:pointAmount at:center radius:radius angle:angle 
		 inContext:context 
		 withColor:color width:width cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN 
	 solidOrDotted:isDotted];
}

- (void)drawStar:(NSInteger)pointAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
	   inContext:(CGContextRef)context 
	   withColor:(UIColor *)color width:(CGFloat)width cap:(CGLineCap)cap join:(CGLineJoin)join 
   solidOrDotted:(kDrawStyle)isDotted {
	
	if (pointAmount < 3) {
		LOG_INFO(@"draw star with less than 3 points", self);
		return;
	}
	
	[self addStar:pointAmount at:center radius:radius angle:angle toContext:context];
	CONTEXT_DRAW_WITH_ARGS(context, color, width, cap, join, isDotted);
}

- (void)fillStar:(NSInteger)pointAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
	   inContext:(CGContextRef)context 
	   withColor:(UIColor *)color {
	
	[self fillStar:pointAmount at:center radius:radius angle:angle 
		 inContext:context 
		 withColor:color fillColor:color width:DEFAULT_LINE_WIDTH cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN 
	 solidOrDotted:kLineSolid 
		  pathMode:kCGPathFill];
}

- (void)fillStar:(NSInteger)pointAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
	   inContext:(CGContextRef)context 
	   withColor:(UIColor *)sColor fillColor:(UIColor *)fColor width:(CGFloat)width cap:(CGLineCap)cap join:(CGLineJoin)join 
   solidOrDotted:(kDrawStyle)isDotted 
		pathMode:(CGPathDrawingMode)mode {
	
	if (pointAmount < 3) {
		LOG_INFO(@"draw star with less than 3 points", self);
		return;
	}
	
	CGContextSaveGState(context);
	[self addStar:pointAmount at:center radius:radius angle:angle toContext:context];
	SET_CONTEXT_WITH_ARGS(context, sColor, fColor, width, cap, join);
	SET_CONTEXT_LINE_STYPE(context, isDotted);
	CGContextDrawPath(context, mode);
	CGContextRestoreGState(context);
}

#pragma mark -

- (void)addFanAt:(CGPoint)center radius:(CGFloat)radius 
			from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise 
	   toContext:(CGContextRef)context {
	
	CGContextMoveToPoint(context, center.x, center.y);
	CGContextAddArc(context, center.x, center.y, radius, DEGREES_TO_RADIANS(startAngle), DEGREES_TO_RADIANS(endAngle), clockwise);
	CGContextClosePath(context);
}

- (void)drawFanAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise 
		inContext:(CGContextRef)context
		withColor:(UIColor *)color {
	
	[self drawFanAt:center radius:radius 
			   from:startAngle to:endAngle clockwise:clockwise 
		  inContext:context 
		  withColor:color width:DEFAULT_LINE_WIDTH cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN 
	  solidOrDotted:kLineSolid];
}

- (void)drawFanAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise
		inContext:(CGContextRef)context 
		withColor:(UIColor *)color width:(CGFloat)width 
	solidOrDotted:(kDrawStyle)isDotted {
	
	[self drawFanAt:center radius:radius from:startAngle to:endAngle clockwise:clockwise 
		  inContext:context 
		  withColor:color width:width cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN
	  solidOrDotted:isDotted];
}

- (void)drawFanAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise
		inContext:(CGContextRef)context 
		withColor:(UIColor *)color width:(CGFloat)width cap:(CGLineCap)cap join:(CGLineJoin)join 
	solidOrDotted:(kDrawStyle)isDotted {
	
	[self addFanAt:center radius:radius from:startAngle to:endAngle clockwise:clockwise toContext:context];
	CONTEXT_DRAW_WITH_ARGS(context, color, width, cap, join, isDotted);
}

- (void)fillFanAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise
		inContext:(CGContextRef)context
		withColor:(UIColor *)color {
	
	CGContextSaveGState(context);
	[self addFanAt:center radius:radius from:startAngle to:endAngle clockwise:clockwise toContext:context];
	SET_CONTEXT_WITH_COLOR(context, color);
	CONTEXT_FILL(context);
	CGContextRestoreGState(context);
}

#pragma mark -

- (void)fillGradient:(UIColor **)colors colorAmount:(NSInteger)count inRect:(CGRect)rect linearOrRadial:(kDrawStyle)isLinear 
		   inContext:(CGContextRef)context {
	CGFloat components[4 * count];
	for	(int i = 0; i < count; i++) {
		const CGFloat * tempComponents = CGColorGetComponents(colors[i].CGColor);
		CGFloat colorAlpha = CGColorGetAlpha(colors[i].CGColor);		
		for (int j = 0; j < 3; j++) {
			components[4 * i + j] = tempComponents[j];
		}
		components[4 * i + 3] = colorAlpha;
	}
	
	[self fillGradientInRect:rect linearOrRadial:isLinear inContext:context withComponents:components amount:count];
}

- (void)fillGradientInRect:(CGRect)rect linearOrRadial:(kDrawStyle)isLinear 
				 inContext:(CGContextRef)context
				withColors:(UIColor *)color, ... {
	
	if (!color) {
		LOG_INFO(@"color is nil", self);
		return;
	}
	
	NSMutableArray * colorArray = [[NSMutableArray alloc] initWithCapacity:0];
	va_list(params);
	va_start(params, color);
	while (color) {
		[colorArray addObject:color];
		color = va_arg(params, UIColor *);
	}
	va_end(params);
	
	int count = [colorArray count];
	CGFloat components[4 * count];
	for (int i = 0; i < count; i++) {
		UIColor * tempColor = (UIColor *) [colorArray objectAtIndex:i];
		const CGFloat * tempComponents = CGColorGetComponents(tempColor.CGColor);
		CGFloat colorAlpha = CGColorGetAlpha(tempColor.CGColor);		
		for (int j = 0; j < 3; j++) {
			components[4 * i + j] = tempComponents[j];
		}
		components[4 * i + 3] = colorAlpha;
	}
	
	[self fillGradientInRect:rect linearOrRadial:isLinear inContext:context withComponents:components amount:count];
}

- (void)fillGradientInRect:(CGRect)rect linearOrRadial:(kDrawStyle)isLinear 
				 inContext:(CGContextRef)context 
			withComponents:(CGFloat *)components amount:(NSInteger)count {
	
	if (count <= 0) {
		LOG_INFO(@"fill without color", self);
		return;
	}
	
	CGContextSaveGState(context);
	
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, nil, count);
	CGColorSpaceRelease(space);
	
	CGContextClipToRect(context, rect);
	if (isLinear) {
		CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), rect.origin.y);
		CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), rect.origin.y + rect.size.height);
		CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 
									kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
		
	} else {
		CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
		CGContextDrawRadialGradient(context, gradient, center, 0, center, DISTANCE_BETWEEN_POINT(center, rect.origin), 
									kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	}
	
	CGContextRestoreGState(context);
}

#pragma mark -

- (void)drawImage:(UIImage *)image at:(CGPoint)position inContext:(CGContextRef)context {
	[self drawImage:image at:position alignment:DEFAULT_ALIGNMENT 
		  inContext:context 
		  withTrans:1 flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
}

- (void)drawImage:(UIImage *)image at:(CGPoint)position 
		inContext:(CGContextRef)context
		withTrans:(CGFloat)alpha {
	[self drawImage:image at:position alignment:DEFAULT_ALIGNMENT 
		  inContext:context 
		  withTrans:alpha flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
}

- (void)drawImage:(UIImage *)image at:(CGPoint)position alignment:(kDrawStyle)alignment inContext:(CGContextRef)context {
	[self drawImage:image at:position alignment:alignment 
		  inContext:context 
		  withTrans:1 flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
}

- (void)drawImage:(UIImage *)image at:(CGPoint)position alignment:(kDrawStyle)alignment
		inContext:(CGContextRef)context
		withTrans:(CGFloat)alpha {
	[self drawImage:image at:position alignment:alignment 
		  inContext:context 
		  withTrans:alpha flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
}

- (void)drawImage:(UIImage *)image at:(CGPoint)position alignment:(kDrawStyle)alignment
		inContext:(CGContextRef)context
		withTrans:(CGFloat)alpha flip:(kDrawStyle)flip rotate:(CGFloat)angle scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY {
	
	if (!image) {
		LOG_INFO(@"draw image without image object", self);
		return;
	}
	
	CGContextSaveGState(context);
	
	CGRect imgRect = CGRectMake(position.x, position.y, image.size.width, image.size.height);
	if (alignment == kAlignmentHcenterTop || alignment == kAlignmentHcenterVcenter || alignment == kAlignmentHcenterBottom) {
		imgRect.origin.x -= imgRect.size.width / 2;
		imgRect.origin.x += imgRect.size.width * (1 - scaleX) / 2;
		imgRect.size.width *= scaleX;
	}
	if (alignment == kAlignmentRightTop || alignment == kAlignmentRightVcenter || alignment == kAlignmentRightBottom) {
		imgRect.origin.x -= imgRect.size.width;
		imgRect.origin.x += imgRect.size.width * (1 - scaleX);
		imgRect.size.width *= scaleX;
	}
	if (alignment == kAlignmentLeftVcenter || alignment == kAlignmentHcenterVcenter || alignment == kAlignmentRightVcenter) {
		imgRect.origin.y -= imgRect.size.height / 2;
		imgRect.origin.y += imgRect.size.height * (1 - scaleX) / 2;
		imgRect.size.height *= scaleY;
	}
	if (alignment == kAlignmentLeftBottom || alignment == kAlignmentHcenterBottom || alignment == kAlignmentRightBottom) {
		imgRect.origin.y -= imgRect.size.height;
		imgRect.origin.y += imgRect.size.height * (1 - scaleX);
		imgRect.size.height *= scaleY;
	} 
	if (alignment == kAlignmentLeftTop) {
		imgRect.size.width *= scaleX;
		imgRect.size.height *= scaleY;
	}
	
	CGContextTranslateCTM(context, imgRect.origin.x, imgRect.origin.y);								
	CGContextTranslateCTM(context, imgRect.size.width / 2, imgRect.size.height / 2);
	CGContextSetAlpha(context, alpha);	
	if (flip == UIImageOrientationUpMirrored || flip == UIImageOrientationDown) {					
		CGContextScaleCTM(context, -1, 1);															
	}																								
	if (flip == UIImageOrientationRightMirrored || flip == UIImageOrientationDown) {				
		CGContextScaleCTM(context, 1, -1);															
	}
	CGContextRotateCTM(context, DEGREES_TO_RADIANS(angle));
	CGContextTranslateCTM(context, -imgRect.size.width / 2, -imgRect.size.height / 2);															
	CGContextTranslateCTM(context, 0, imgRect.size.height);											
	CGContextScaleCTM(context, 1, -1);																
	CGContextTranslateCTM(context, -imgRect.origin.x, -imgRect.origin.y);	
	
	CGImageRef imgRef = CGImageRetain(image.CGImage);
	CGContextDrawImage(context, imgRect, imgRef);
	
	CGContextRestoreGState(context);
}

- (void)drawImageNamed:(NSString *)name at:(CGPoint)position inContext:(CGContextRef)context {
	[self drawImageNamed:name at:position alignment:DEFAULT_ALIGNMENT 
			   inContext:context 
			   withTrans:1 flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
}

- (void)drawImageNamed:(NSString *)name at:(CGPoint)position 
			 inContext:(CGContextRef)context
			 withTrans:(CGFloat)alpha {
	
	[self drawImageNamed:name at:position alignment:DEFAULT_ALIGNMENT 
			   inContext:context 
			   withTrans:alpha flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
}

- (void)drawImageNamed:(NSString *)name at:(CGPoint)position alignment:(kDrawStyle)alignment inContext:(CGContextRef)context {
	[self drawImageNamed:name at:position alignment:alignment 
			   inContext:context 
			   withTrans:1 flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
}

- (void)drawImageNamed:(NSString *)name at:(CGPoint)position alignment:(kDrawStyle)alignment 
			 inContext:(CGContextRef)context
			 withTrans:(CGFloat)alpha {
	
	[self drawImageNamed:name at:position alignment:alignment 
			   inContext:context 
			   withTrans:alpha flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
}

- (void)drawImageNamed:(NSString *)name at:(CGPoint)position alignment:(kDrawStyle)alignment  
			 inContext:(CGContextRef)context
			 withTrans:(CGFloat)alpha flip:(kDrawStyle)flip rotate:(CGFloat)angle scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY {
	
	if (!name) {
		LOG_INFO(@"draw image without name", self);
		return;
	}
	
	UIImage * image = [UIImage imageNamed:name];
	[self drawImage:image at:position alignment:alignment 
		  inContext:context 
		  withTrans:alpha flip:flip rotate:angle scaleX:scaleX scaleY:scaleY];
	[image release];
}

- (void)fillImage:(UIImage *)image inRect:(CGRect)rect by:(kDrawStyle)fillType inContext:(CGContextRef)context {
	
	if (!image) {
		LOG_INFO(@"fill image without image object", self);
		return;
	}
	
	if (fillType == kFillByScale) {
		[image drawInRect:rect];
		
	} else {
		[self fillImage:image inRect:rect by:fillType inContext:context withTrans:1 flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
	}	
}

- (void)fillImage:(UIImage *)image inRect:(CGRect)rect by:(kDrawStyle)fillType 
		inContext:(CGContextRef)context 
		withTrans:(CGFloat)alpha {
	
	if (!image) {
		LOG_INFO(@"fill image without image object", self);
		return;
	}
	
	if (fillType == kFillByScale) {
		[image drawInRect:rect blendMode:kCGBlendModeNormal alpha:alpha];
		
	} else {
		[self fillImage:image inRect:rect by:fillType 
			  inContext:context 
			  withTrans:alpha flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
	}
}

- (void)fillImage:(UIImage *)image inRect:(CGRect)rect by:(kDrawStyle)fillType  
		inContext:(CGContextRef)context 
		withTrans:(CGFloat)alpha flip:(kDrawStyle)flip rotate:(CGFloat)angle scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY {
	
	if (!image) {
		LOG_INFO(@"fill image without image object", self);
		return;
	}
	
	CGContextSaveGState(context);
	
	CGRect imgRect = CGRectMake(0, 0, image.size.width, image.size.height);
	if (fillType == kFillByScale) {
		scaleX = 1;
		scaleY = 1;
	}
	
	CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);								
	CGContextTranslateCTM(context, rect.size.width / 2, rect.size.height / 2);					
	CGContextRotateCTM(context, angle);															
	CGContextTranslateCTM(context, -rect.size.width / 2, -rect.size.height / 2);					
	CGContextScaleCTM(context, scaleX, scaleY);													
	CGContextSetAlpha(context, alpha);															
	CGContextTranslateCTM(context, 0, rect.size.height / scaleY);								
	CGContextScaleCTM(context, 1, -1);																
	if (flip == UIImageOrientationUpMirrored || flip == UIImageOrientationDown) {					
		CGContextTranslateCTM(context, rect.size.width, 0);										
		CGContextScaleCTM(context, -1, 1);															
	}																								
	if (flip == UIImageOrientationRightMirrored || flip == UIImageOrientationDown) {				
		CGContextTranslateCTM(context, 0, rect.size.height / scaleY);							
		CGContextScaleCTM(context, 1, -1);															
	}																								
	CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
	
	CGImageRef imgRef = CGImageRetain(image.CGImage);
	if (fillType == kFillByScale) {
		CGContextDrawImage(context, rect, imgRef);
	} else {
		imgRect.origin = rect.origin;
		imgRect.origin.y -= (rect.size.height - imgRect.size.height * scaleY);
		rect.size.width /= scaleX;
		rect.size.height /= scaleY;
		CGContextClipToRect(context, rect);
		CGContextDrawTiledImage(context, imgRect, imgRef);
	}
	
	CGContextRestoreGState(context);
}

- (void)fillImageNamed:(NSString *)name inRect:(CGRect)rect by:(kDrawStyle)fillType inContext:(CGContextRef)context {
	
	[self fillImageNamed:name inRect:rect by:fillType 
			   inContext:context 
			   withTrans:1 flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
}

- (void)fillImageNamed:(NSString *)name inRect:(CGRect)rect by:(kDrawStyle)fillType
			 inContext:(CGContextRef)context
			 withTrans:(CGFloat)alpha {
	
	[self fillImageNamed:name inRect:rect by:fillType 
			   inContext:context 
			   withTrans:alpha flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
}

- (void)fillImageNamed:(NSString *)name inRect:(CGRect)rect by:(kDrawStyle)fillType 
			 inContext:(CGContextRef)context
			 withTrans:(CGFloat)alpha flip:(kDrawStyle)flip rotate:(CGFloat)angle scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY {
	
	if (!name) {
		LOG_INFO(@"fill image without name", self);
		return;
	}
	
	UIImage * image = [UIImage imageNamed:name];
	[self fillImage:image inRect:rect by:fillType 
		  inContext:context 
		  withTrans:alpha flip:flip rotate:angle scaleX:scaleX scaleY:scaleY];
	[image release];
}

#pragma mark -

- (void)drawPDFNamed:(NSString *)name inContext:(CGContextRef)context {
	[self drawPDFNamed:name inRect:CGContextGetClipBoundingBox(context) inContext:context];
}

- (void)drawPDFNamed:(NSString *)name at:(CGPoint)position inContext:(CGContextRef)context {
	CGRect rect = CGContextGetClipBoundingBox(context);
	rect.origin = position;
	[self drawPDFNamed:name inRect:rect inContext:context];	
}

- (void)drawPDFNamed:(NSString *)name inRect:(CGRect)rect inContext:(CGContextRef)context {	
	if (!name) {
		LOG_INFO(@"draw PDF without name", self);
		return;
	}
	
	CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), (CFStringRef)name, NULL, NULL);
	CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
	CFRelease(pdfURL);
	
	CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
	CGContextTranslateCTM(context, 0, rect.size.height);
	CGContextScaleCTM(context, 1, -1);
	CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
	
	CGPDFPageRef page = CGPDFDocumentGetPage(pdf, 1);
	
	CGContextSaveGState(context);
	
	CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, rect, 0, true);
	CGContextConcatCTM(context, pdfTransform);
	
	CGContextDrawPDFPage(context, page);
	
	CGContextRestoreGState(context);
}

#pragma mark -

- (void)drawText:(NSString *)content inRect:(CGRect)rect inContext:(CGContextRef)context {
	
	[self drawText:content inRect:rect
		 inContext:context 
		 withColor:DEFAULT_COLOR font:DEFAULT_FONT size:DEFAULT_FONT_SIZE 
	   strokeColor:DEFAULT_COLOR 
		  pathMode:kCGTextFill];
}

- (void)drawText:(NSString *)content inRect:(CGRect)rect inContext:(CGContextRef)context withColor:(UIColor *)color {
	
	[self drawText:content inRect:rect
		 inContext:context 
		 withColor:color font:DEFAULT_FONT size:DEFAULT_FONT_SIZE 
	   strokeColor:DEFAULT_COLOR 
		  pathMode:kCGTextFill];
}

- (void)drawText:(NSString *)content inRect:(CGRect)rect 
	   inContext:(CGContextRef)context 
	   withColor:(UIColor *)color font:(NSString *)font size:(NSInteger)size {
	
	[self drawText:content inRect:rect
		 inContext:context 
		 withColor:color font:font size:size 
	   strokeColor:DEFAULT_COLOR 
		  pathMode:kCGTextFill];
}

- (void)drawText:(NSString *)content inRect:(CGRect)rect 
	   inContext:(CGContextRef)context 
	   withColor:(UIColor *)color font:(NSString *)font size:(NSInteger)size 
	 strokeColor:(UIColor *)sColor 
		pathMode:(CGTextDrawingMode)mode {	
	
	if (!content) {
		LOG_INFO(@"draw text without content", self);
		return;
	}
	
	CGContextSaveGState(context);
	
	CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
	CGContextScaleCTM(context, 1, -1);
	CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
	
	CGContextSetStrokeColorWithColor(context, sColor.CGColor);
	CGContextSetFillColorWithColor(context, color.CGColor);	
	CGContextSelectFont(context, [font UTF8String], size, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode(context, mode);
	CGContextShowTextAtPoint(context, rect.origin.x, rect.origin.y - size, [content UTF8String], textLength([content UTF8String]));
	
	CGContextRestoreGState(context);
}

- (void)drawGlyphs:(CGGlyph *)glyphs glyphAmount:(NSInteger)count inRect:(CGRect)rect inContext:(CGContextRef)context {
	
	[self drawGlyphs:glyphs glyphAmount:count inRect:rect
		   inContext:context 
		   withColor:DEFAULT_COLOR font:DEFAULT_FONT size:DEFAULT_FONT_SIZE 
		 strokeColor:DEFAULT_COLOR 
			pathMode:kCGTextFill];
}

- (void)drawGlyphs:(CGGlyph *)glyphs glyphAmount:(NSInteger)count inRect:(CGRect)rect 
		 inContext:(CGContextRef)context 
		 withColor:(UIColor *)color {
	
	[self drawGlyphs:glyphs glyphAmount:count inRect:rect
		   inContext:context 
		   withColor:color font:DEFAULT_FONT size:DEFAULT_FONT_SIZE 
		 strokeColor:color 
			pathMode:kCGTextFill];
}

- (void)drawGlyphs:(CGGlyph *)glyphs glyphAmount:(NSInteger)count inRect:(CGRect)rect 
		 inContext:(CGContextRef)context 
		 withColor:(UIColor *)color font:(NSString *)font size:(NSInteger)size {
	
	[self drawGlyphs:glyphs glyphAmount:count inRect:rect
		   inContext:context 
		   withColor:DEFAULT_COLOR font:DEFAULT_FONT size:DEFAULT_FONT_SIZE 
		 strokeColor:DEFAULT_COLOR 
			pathMode:kCGTextFill];
	
}

- (void)drawGlyphs:(CGGlyph *)glyphs glyphAmount:(NSInteger)count inRect:(CGRect)rect 
		 inContext:(CGContextRef)context 
		 withColor:(UIColor *)color font:(NSString *)font size:(NSInteger)size 
	   strokeColor:(UIColor *)sColor 
		  pathMode:(CGTextDrawingMode)mode {	
	
	if (!glyphs) {
		LOG_INFO(@"draw text without content", self);
		return;
	}
	
	CGContextSaveGState(context);
	
	CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
	CGContextScaleCTM(context, 1, -1);
	CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
	
	CGFontRef fontRef = CGFontCreateWithFontName((CFStringRef)font);
	CGContextSetStrokeColorWithColor(context, sColor.CGColor);
	CGContextSetFillColorWithColor(context, color.CGColor);		
	CGContextSetFont(context, fontRef);
	CGContextSetFontSize(context, size);
	CGContextSetTextDrawingMode(context, mode);
	CGContextShowGlyphsAtPoint(context, rect.origin.x, rect.origin.y, glyphs, count);
	CGFontRelease(fontRef);
	
	CGContextRestoreGState(context);
}

@end


#pragma mark -
#pragma mark === Draw Primitives use OpenGL ===
#pragma mark -

@implementation PrimitivesGL

@synthesize checkError;

#pragma mark -

- (id)initWithDeviceSize:(CGSize)size {
	if (self = [super init]) {
		deviceSize = size;
		return self;
	}
	return nil;
}

#pragma mark -

- (void)cleanScreenInContext:(EAGLContext *)context {
	[self cleanRect:CGRectMake(0, 0, deviceSize.width, deviceSize.height) inContext:context withColor:DEFAULT_COLOR];
}

- (void)cleanScreenInContext:(EAGLContext *)context withColor:(UIColor *)color {
	[self cleanRect:CGRectMake(0, 0, deviceSize.width, deviceSize.height) inContext:context withColor:color];
}

- (void)cleanRect:(CGRect)rect inContext:(EAGLContext *)context withColor:(UIColor *)color {
	const CGFloat * components = CGColorGetComponents(color.CGColor);
	CGFloat alpha = CGColorGetAlpha(color.CGColor);
	glClearColor(components[0], components[1], components[2], alpha);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

- (void)checkGLError:(BOOL)visibleCheck {
    GLenum error = glGetError();
    switch (error) {
        case GL_INVALID_ENUM:
            NSLog(@"GL Error: Enum argument is out of range");
            break;
        case GL_INVALID_VALUE:
            NSLog(@"GL Error: Numeric value is out of range");
            break;
        case GL_INVALID_OPERATION:
            NSLog(@"GL Error: Operation illegal in current state");
            break;
        case GL_STACK_OVERFLOW:
            NSLog(@"GL Error: Command would cause a stack overflow");
            break;
        case GL_STACK_UNDERFLOW:
            NSLog(@"GL Error: Command would cause a stack underflow");
            break;
        case GL_OUT_OF_MEMORY:
            NSLog(@"GL Error: Not enough memory to execute command");
            break;
        case GL_NO_ERROR:
            if (visibleCheck) {
                NSLog(@"No GL Error");
            }
            break;
        default:
            NSLog(@"Unknown GL Error");
            break;
    }
}

- (CGSize)loadTextureWithImage:(UIImage *)uiImage orName:(NSString *)imageName {
	if (!uiImage) {
		uiImage = [UIImage imageNamed:imageName];
	}
	CGImageRef image = uiImage.CGImage;
	CGContextRef texContext;
	GLubyte* bytes = nil;	
	size_t	width, height;
	
	if (image) {
		width = CGImageGetWidth(image);
		height = CGImageGetHeight(image);
		
		bytes = (GLubyte*) calloc(width*height*4, sizeof(GLubyte));
		// Uses the bitmatp creation function provided by the Core Graphics framework. 
		texContext = CGBitmapContextCreate(bytes, width, height, 8, width * 4, CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
		// After you create the context, you can draw the image to the context.
		CGContextDrawImage(texContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), image);
		// You don't need the context at this point, so you need to release it to avoid memory leaks.
		CGContextRelease(texContext);
		
		// setup texture parameters
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, bytes);
		free(bytes);
	}
	
	return CGSizeMake(width, height);
}

#pragma mark -

- (void)drawPoint:(CGPoint)point inContext:(EAGLContext *)context withColor:(UIColor *)color {
	[self drawPoint:point inContext:context withColor:color width:DEFAULT_LINE_WIDTH];
}

- (void)drawPoint:(CGPoint)point inContext:(EAGLContext *)context withColor:(UIColor *)color width:(GLfloat)width {
	GLfloat vertices[] = {
		CG_X_TO_GL(point.x, deviceSize),	CG_Y_TO_GL(point.y, deviceSize),	DEFAULT_DEPTH
	};
	
	GL_DRAW_ARRAY(context, color, nil, width, vertices, 0, 1, GL_POINTS);
}

- (void)drawPoints:(CGPoint *)points pointAmount:(NSInteger)count inContext:(EAGLContext *)context withColor:(UIColor *)color {
	[self drawPoints:points pointAmount:count inContext:context withColor:color width:DEFAULT_LINE_WIDTH];
}

- (void)drawPoints:(CGPoint *)points pointAmount:(NSInteger)count 
		 inContext:(EAGLContext *)context 
		 withColor:(UIColor *)color width:(GLfloat)width {
	
	if (count < 1) {
		LOG_INFO(@"draw point without point", self);
		return;
	}
	
	GLfloat vertices[3 * count];
	for (int i = 0; i < count; i++) {
		vertices[3 * i + 0] = CG_X_TO_GL(points[i].x, deviceSize);
		vertices[3 * i + 1] = CG_Y_TO_GL(points[i].y, deviceSize);
		vertices[3 * i + 2] = DEFAULT_DEPTH;
	}		
	
	GL_DRAW_ARRAY(context, color, nil, width, vertices, 0, count, GL_POINTS);
}

- (void)drawPointsInContext:(EAGLContext *)context withColor:(UIColor *)color width:(CGFloat)width 
					 points:(NSString *)s_point, ... {
	
	if (!s_point) {
		LOG_INFO(@"draw point without point", self);
		return;
	}
	
	va_list params;
	va_start(params, s_point);
	NSMutableArray * tempArray = [[NSMutableArray alloc] initWithCapacity:0];
	NSString * currSPoint = s_point;
	while (currSPoint) {
		[tempArray addObject:currSPoint];
		currSPoint = va_arg(params, NSString *);
	}
	va_end(params);
	
	NSInteger count = [tempArray count];
	
	if (count < 2) {
		LOG_INFO(@"draw lines with less than 2 points",self);
		return ;
	}
	
	GLfloat vertices[3 * count];
	CGPoint point;
	for (int i = 0; i < count; i++) {
		point = pString((NSString *) [tempArray	objectAtIndex:i]);
		vertices[3 * i + 0] = CG_X_TO_GL(point.x, deviceSize);
		vertices[3 * i + 1] = CG_Y_TO_GL(point.y, deviceSize);
		vertices[3 * i + 2] = DEFAULT_DEPTH;
	}
	[tempArray release];
	
	GL_DRAW_ARRAY(context, color, nil, width, vertices, 0, count, GL_POINTS);
}

#pragma mark -

- (void)drawLineFrom:(CGPoint)startPoint to:(CGPoint)endPoint inContext:(EAGLContext *)context withColor:(UIColor *)color {
	[self drawLineFrom:startPoint to:endPoint inContext:context withColor:color width:DEFAULT_LINE_WIDTH];
}

- (void)drawLineFrom:(CGPoint)startPoint to:(CGPoint)endPoint 
		   inContext:(EAGLContext *)context 
		   withColor:(UIColor *)color width:(CGFloat)width  {
	
	GLfloat vertices[] = {
		CG_X_TO_GL(startPoint.x, deviceSize),
		CG_Y_TO_GL(startPoint.y, deviceSize),
		DEFAULT_DEPTH,
		
		CG_X_TO_GL(endPoint.x, deviceSize),
		CG_Y_TO_GL(endPoint.y, deviceSize),
		DEFAULT_DEPTH
	};
	
	GL_DRAW_ARRAY(context, color, nil, width, vertices, 0, 2, GL_LINES);
}

- (void)drawLines:(CGPoint *)points pointAmount:(NSInteger)count inContext:(EAGLContext *)context withColor:(UIColor *)color {
	[self drawLines:points pointAmount:count inContext:context withColor:color width:DEFAULT_LINE_WIDTH joinOrSeg:kLineJoin];
}

- (void)drawLines:(CGPoint *)points pointAmount:(NSInteger)count 
		inContext:(EAGLContext *)context 
		withColor:(UIColor *)color width:(CGFloat)width {
	
	[self drawLines:points pointAmount:count inContext:context withColor:color width:width joinOrSeg:kLineJoin];
}

- (void)drawLines:(CGPoint *)points pointAmount:(NSInteger)count 
		inContext:(EAGLContext *)context 
		withColor:(UIColor *)color width:(CGFloat)width 
		joinOrSeg:(kDrawStyle)isSeg {
	
	if (count < 2) {
		LOG_INFO(@"draw lines with less than 2 points",self);
		return ;
	}	
	
	if (isSeg) {
		GLfloat vertices[3 * count];
		for (int i = 0; i < count; i++) {
			vertices[3 * i + 0] = CG_X_TO_GL(points[i].x, deviceSize);
			vertices[3 * i + 1] = CG_Y_TO_GL(points[i].y, deviceSize);
			vertices[3 * i + 2] = DEFAULT_DEPTH;
		}		
		
		GL_DRAW_ARRAY(context, color, nil, width, vertices, 0, count, GL_LINES);
		
	} else {
		GLfloat vertices[6 * (count - 1)];
		for (int i = 0; i < count - 1; i++) {
			vertices[6 * i + 0] = CG_X_TO_GL(points[i].x, deviceSize);
			vertices[6 * i + 1] = CG_Y_TO_GL(points[i].y, deviceSize);
			vertices[6 * i + 2] = DEFAULT_DEPTH;
			vertices[6 * i + 3] = CG_X_TO_GL(points[i + 1].x, deviceSize);
			vertices[6 * i + 4] = CG_Y_TO_GL(points[i + 1].y, deviceSize);
			vertices[6 * i + 5] = DEFAULT_DEPTH;
		}		
		
		GL_DRAW_ARRAY(context, color, nil, width, vertices, 0, 2 * (count - 1), GL_LINES);
	}	
}

- (void)drawLinesInContext:(EAGLContext *)context 
				 withColor:(UIColor *)color width:(CGFloat)width
				 joinOrSeg:(kDrawStyle)isSeg  
				   sPoints:(NSString *)s_point, ... {
	
	va_list params;
	va_start(params, s_point);
	NSMutableArray * tempArray = [[NSMutableArray alloc] initWithCapacity:0];
	NSString * currSPoint = s_point;
	while (currSPoint) {
		[tempArray addObject:currSPoint];
		currSPoint = va_arg(params, NSString *);
	}
	va_end(params);
	
	NSInteger count = [tempArray count];
	CGPoint points[count];
	for (int i = 0; i < count; i++) {
		points[i] = pString((NSString *) [tempArray	objectAtIndex:i]);
	}
	[tempArray release];
	
	[self drawLines:points pointAmount:count inContext:context withColor:color width:width joinOrSeg:isSeg];
}

#pragma mark -

- (void)drawRect:(CGRect)rect inContext:(EAGLContext *)context withColor:(UIColor *)color {
	[self drawRect:rect inContext:context withColor:color width:DEFAULT_LINE_WIDTH];
}

- (void)drawRect:(CGRect)rect inContext:(EAGLContext *)context withColor:(UIColor *)color width:(CGFloat)width {
	GLfloat vertices[] = {
		CG_X_TO_GL(rect.origin.x, deviceSize),
		CG_Y_TO_GL(rect.origin.y, deviceSize),
		DEFAULT_DEPTH,
		
		CG_X_TO_GL(rect.origin.x, deviceSize),
		CG_Y_TO_GL(rect.origin.y + rect.size.height, deviceSize),
		DEFAULT_DEPTH,
		
		CG_X_TO_GL(rect.origin.x + rect.size.width, deviceSize),
		CG_Y_TO_GL(rect.origin.y + rect.size.height, deviceSize),
		DEFAULT_DEPTH,
		
		CG_X_TO_GL(rect.origin.x + rect.size.width, deviceSize),
		CG_Y_TO_GL(rect.origin.y, deviceSize),
		DEFAULT_DEPTH
	};
		
	GL_DRAW_ARRAY(context, color, nil, width, vertices, 0, 4, GL_LINE_LOOP);
}

- (void)fillRect:(CGRect)rect inContext:(EAGLContext *)context withColor:(UIColor *)color gradient:(const GLfloat *)glColors {
	GLfloat vertices[] = {
		CG_X_TO_GL(rect.origin.x, deviceSize),
		CG_Y_TO_GL(rect.origin.y, deviceSize),
		DEFAULT_DEPTH,
		
		CG_X_TO_GL(rect.origin.x, deviceSize),
		CG_Y_TO_GL(rect.origin.y + rect.size.height, deviceSize),
		DEFAULT_DEPTH,
		
		CG_X_TO_GL(rect.origin.x + rect.size.width, deviceSize),
		CG_Y_TO_GL(rect.origin.y + rect.size.height, deviceSize),
		DEFAULT_DEPTH,
		
		CG_X_TO_GL(rect.origin.x + rect.size.width, deviceSize),
		CG_Y_TO_GL(rect.origin.y, deviceSize),
		DEFAULT_DEPTH
	};
	
	GL_DRAW_ARRAY(context, color, glColors, DEFAULT_LINE_WIDTH, vertices, 0, 4, GL_TRIANGLE_FAN);
}

- (void)drawRects:(CGRect *)rects rectAmount:(NSInteger)count inContext:(EAGLContext *)context withColor:(UIColor *)color {
	[self drawRects:rects rectAmount:count inContext:context withColor:color width:DEFAULT_LINE_WIDTH];
}

- (void)drawRects:(CGRect *)rects rectAmount:(NSInteger)count 
		inContext:(EAGLContext *)context 
		withColor:(UIColor *)color width:(CGFloat)width {
	
	for (int i = 0; i < count; i++) {
		[self drawRect:rects[i] inContext:context withColor:color width:DEFAULT_LINE_WIDTH];
	}
}

- (void)fillRects:(CGRect *)rects rectAmount:(NSInteger)count 
		inContext:(EAGLContext *)context 
		withColor:(UIColor *)color gradient:(const GLfloat *)glColors {
	for (int i = 0; i < count; i++) {
		[self fillRect:rects[i] inContext:context withColor:color gradient:glColors];
	}
}

- (void)drawRectsInContext:(EAGLContext *)context withColor:(UIColor *)color width:(CGFloat)width 
					sRects:(NSString *)simgRect, ... {
	
	va_list params;
	va_start(params, simgRect);
	NSMutableArray * tempArray = [[NSMutableArray alloc] initWithCapacity:0];
	NSString * currSRect = simgRect;
	while (currSRect) {
		[tempArray addObject:currSRect];
		currSRect = va_arg(params, NSString *);
	}
	va_end(params);
	
	NSInteger count = [tempArray count];
	CGRect rect;
	for (int i = 0; i < count; i++) {
		rect = rString((NSString *) [tempArray	objectAtIndex:i]);
		[self drawRect:rect inContext:context withColor:color width:width];
	}
	[tempArray release];
}

- (void)fillRectsInContext:(EAGLContext *)context withColor:(UIColor *)color gradient:(const GLfloat *)glColors
					sRects:(NSString *)simgRect, ... {
	
	va_list params;
	va_start(params, simgRect);
	NSMutableArray * tempArray = [[NSMutableArray alloc] initWithCapacity:0];
	NSString * currSRect = simgRect;
	while (currSRect) {
		[tempArray addObject:currSRect];
		currSRect = va_arg(params, NSString *);
	}
	va_end(params);
	
	NSInteger count = [tempArray count];
	CGRect rect;
	for (int i = 0; i < count; i++) {
		rect = rString((NSString *) [tempArray	objectAtIndex:i]);
		[self fillRect:rect inContext:context withColor:color gradient:glColors];
	}
	[tempArray release];
}

#pragma mark -

- (void)drawEllipse:(CGRect)rect inContext:(EAGLContext *)context withColor:(UIColor *)color {
	[self drawEllipse:rect inContext:context withColor:color width:DEFAULT_LINE_WIDTH];
}

- (void)drawEllipse:(CGRect)rect inContext:(EAGLContext *)context withColor:(UIColor *)color width:(CGFloat)width {
	CGFloat xRadius = rect.size.width / 2,	yRadius = rect.size.height / 2;
	CGFloat xMid = CGRectGetMidX(rect),		yMid = CGRectGetMidY(rect);
	GLfloat vertices[3 * 360];
	for (int i = 0; i < 360; i++) {
		vertices[3 * i + 0] = CG_X_TO_GL(xMid + xRadius * cos(DEGREES_TO_RADIANS(i)), deviceSize);
		vertices[3 * i + 1] = CG_Y_TO_GL(yMid + yRadius * sin(DEGREES_TO_RADIANS(i)), deviceSize);
		vertices[3 * i + 2] = DEFAULT_DEPTH;
	}
	
	GL_DRAW_ARRAY(context, color, nil, width, vertices, 0, 360, GL_LINE_LOOP);
}

- (void)fillEllipse:(CGRect)rect 
		  inContext:(EAGLContext *)context 
		  withColor:(UIColor *)color gradient:(const GLfloat *)glColors {
	CGFloat xRadius = rect.size.width / 2,	yRadius = rect.size.height / 2;
	CGFloat xMid = CGRectGetMidX(rect),		yMid = CGRectGetMidY(rect);
	GLfloat vertices[3 * 360];
	for (int i = 0; i < 360; i++) {
		vertices[3 * i + 0] = CG_X_TO_GL(xMid + xRadius * cos(DEGREES_TO_RADIANS(i)), deviceSize);
		vertices[3 * i + 1] = CG_Y_TO_GL(yMid + yRadius * sin(DEGREES_TO_RADIANS(i)), deviceSize);
		vertices[3 * i + 2] = DEFAULT_DEPTH;
	}
	
	GL_DRAW_ARRAY(context, color, glColors, DEFAULT_LINE_WIDTH, vertices, 0, 360, GL_TRIANGLE_FAN);
}

- (void)drawEllipses:(CGRect *)rects rectAmount:(NSInteger)count inContext:(EAGLContext *)context withColor:(UIColor *)color {
	[self drawEllipses:rects rectAmount:count inContext:context withColor:color width:DEFAULT_LINE_WIDTH];
}

- (void)drawEllipses:(CGRect *)rects rectAmount:(NSInteger)count 
		   inContext:(EAGLContext *)context 
		   withColor:(UIColor *)color width:(CGFloat)width {
	
	for (int i = 0; i < count; i++) {
		[self drawEllipse:rects[i] inContext:context withColor:color width:width];
	}
}

- (void)fillEllipses:(CGRect *)rects rectAmount:(NSInteger)count 
		   inContext:(EAGLContext *)context 
		   withColor:(UIColor *)color gradient:(const GLfloat *)glColors {
	for (int i = 0; i < count; i++) {
		[self fillEllipse:rects[i] inContext:context withColor:color gradient:glColors];
	}
}

- (void)drawEllipsesInContext:(EAGLContext *)context withColor:(UIColor *)color width:(CGFloat)width 
					   sRects:(NSString *)simgRect, ... {
	
	va_list params;
	va_start(params, simgRect);
	NSMutableArray * tempArray = [[NSMutableArray alloc] initWithCapacity:0];
	NSString * currSRect = simgRect;
	while (currSRect) {
		[tempArray addObject:currSRect];
		currSRect = va_arg(params, NSString *);
	}
	va_end(params);
	
	NSInteger count = [tempArray count];
	CGRect rect;
	for (int i = 0; i < count; i++) {
		rect = rString((NSString *) [tempArray	objectAtIndex:i]);
		[self drawEllipse:rect inContext:context withColor:color width:width];
	}
	[tempArray release];
}

- (void)fillEllipsesInContext:(EAGLContext *)context withColor:(UIColor *)color gradient:(const GLfloat *)glColors 
					   sRects:(NSString *)simgRect, ... {
	
	va_list params;
	va_start(params, simgRect);
	NSMutableArray * tempArray = [[NSMutableArray alloc] initWithCapacity:0];
	NSString * currSRect = simgRect;
	while (currSRect) {
		[tempArray addObject:currSRect];
		currSRect = va_arg(params, NSString *);
	}
	va_end(params);
	
	NSInteger count = [tempArray count];
	CGRect rect;
	for (int i = 0; i < count; i++) {
		rect = rString((NSString *) [tempArray	objectAtIndex:i]);
		[self fillEllipse:rect inContext:context withColor:color gradient:glColors];
	}
	[tempArray release];
}

#pragma mark -

- (void)drawArcAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise 
		inContext:(EAGLContext *)context 
		withColor:(UIColor *)color {
	
	[self drawArcAt:center radius:radius 
			   from:startAngle to:endAngle clockwise:clockwise 
		  inContext:context 
		  withColor:color width:DEFAULT_LINE_WIDTH];
}

- (void)drawArcAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise 
		inContext:(EAGLContext *)context 
		withColor:(UIColor *)color width:(CGFloat)width {
	
	if (clockwise == kArcCounterClockwise) {
		SWAP(startAngle, endAngle);
	}
	NSInteger count = (NSInteger)(endAngle - startAngle + 360) % 360;
	GLfloat vertices[3 * count];
	for (int i = 0; i < count - 1; i++) {
		vertices[3 * i + 0] = CG_X_TO_GL(center.x + radius * cos(DEGREES_TO_RADIANS(i + startAngle)), deviceSize);
		vertices[3 * i + 1] = CG_Y_TO_GL(center.y + radius * sin(DEGREES_TO_RADIANS(i + startAngle)), deviceSize);
		vertices[3 * i + 2] = DEFAULT_DEPTH;
	}
	
	GL_DRAW_ARRAY(context, color, nil, width, vertices, 0, count - 1, GL_LINE_STRIP);
}

- (void)fillArcAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise 
		inContext:(EAGLContext *)context 
		withColor:(UIColor *)color gradient:(const GLfloat *)glColors {
	
	if (clockwise == kArcCounterClockwise) {
		SWAP(startAngle, endAngle);
	}
	NSInteger count = (NSInteger)(endAngle - startAngle + 360) % 360;
	GLfloat vertices[3 * count];
	for (int i = 0; i < count; i++) {
		vertices[3 * i + 0] = CG_X_TO_GL(center.x + radius * cos(DEGREES_TO_RADIANS(i + startAngle)), deviceSize);
		vertices[3 * i + 1] = CG_Y_TO_GL(center.y + radius * sin(DEGREES_TO_RADIANS(i + startAngle)), deviceSize);
		vertices[3 * i + 2] = DEFAULT_DEPTH;
	}
	
	GL_DRAW_ARRAY(context, color, glColors, DEFAULT_LINE_WIDTH, vertices, 0, count, GL_TRIANGLE_FAN);	
}

- (void)drawArcFrom:(CGPoint)startPoint to:(CGPoint)endPoint radius:(CGFloat)radius clockwise:(kDrawStyle)clockwise 
		  inContext:(EAGLContext *)context 
		  withColor:(UIColor *)color {
	
	[self drawArcFrom:startPoint to:endPoint radius:radius clockwise:clockwise 
			inContext:context 
			withColor:color width:DEFAULT_LINE_WIDTH];
}

- (void)drawArcFrom:(CGPoint)startPoint to:(CGPoint)endPoint radius:(CGFloat)radius clockwise:(kDrawStyle)clockwise 
		  inContext:(EAGLContext *)context 
		  withColor:(UIColor *)color width:(CGFloat)width {
	
	if (CGPointEqualToPoint(startPoint, endPoint)) {
		[self drawPoint:startPoint inContext:context withColor:color width:width];
		
	} else {
		radius = MAX(radius, DISTANCE_BETWEEN_POINT(startPoint, endPoint) / 2);
		CGPoint center = [Primitives centerOfArcFrom:startPoint to:endPoint withRadius:radius clockwise:clockwise];
		CGFloat startAngle = [Primitives angleBetweenPoint:center andPoint:startPoint];
		CGFloat endAngle = [Primitives angleBetweenPoint:center andPoint:endPoint];
		[self drawArcAt:center radius:radius 
				   from:startAngle to:endAngle clockwise:clockwise 
			  inContext:context 
			  withColor:color width:width];	
	}
}

- (void)fillArcFrom:(CGPoint)startPoint to:(CGPoint)endPoint radius:(CGFloat)radius clockwise:(kDrawStyle)clockwise 
		  inContext:(EAGLContext *)context 
		  withColor:(UIColor *)color gradient:(const GLfloat *)glColors {
	
	if (CGPointEqualToPoint(startPoint, endPoint)) {
		[self drawPoint:startPoint inContext:context withColor:color width:DEFAULT_LINE_WIDTH];
		
	} else {
		radius = MAX(radius, DISTANCE_BETWEEN_POINT(startPoint, endPoint) / 2);
		CGPoint center = [Primitives centerOfArcFrom:startPoint to:endPoint withRadius:radius clockwise:clockwise];
		CGFloat startAngle = [Primitives angleBetweenPoint:center andPoint:startPoint];
		CGFloat endAngle = [Primitives angleBetweenPoint:center andPoint:endPoint];
		[self fillArcAt:center radius:radius 
				   from:startAngle to:endAngle clockwise:clockwise 
			  inContext:context 
			  withColor:color gradient:glColors];		
	}
}

#pragma mark -

- (void)drawBezierCurve:(kBezier)bPoints inContext:(EAGLContext *)context withColor:(UIColor *)color {
	[self drawBezierCurve:bPoints inContext:context withColor:color width:DEFAULT_LINE_WIDTH];
}

- (void)drawBezierCurve:(kBezier)bPoints inContext:(EAGLContext *)context withColor:(UIColor *)color width:(CGFloat)width {
	if (CGPointEqualToPoint(bPoints.sp, bPoints.ep)) {
		[self drawPoint:bPoints.sp inContext:context withColor:color width:width];
		
	} else {
		NSInteger segments = abs(bPoints.sp.x - bPoints.ep.x);
		GLfloat vertices[3 * segments];
		CGFloat t = 0;
		if (CGPointEqualToPoint(bPoints.cp1, bPoints.cp2)) {
			for (int i = 0; i < segments; i++) {				
				vertices[i * 3] = CG_X_TO_GL(powf(1 - t, 2) * bPoints.sp.x + 2.0f * (1 - t) * t * bPoints.cp1.x + t * t * bPoints.ep.x, deviceSize);
				vertices[i * 3 + 1] = CG_Y_TO_GL(powf(1 - t, 2) * bPoints.sp.y + 2.0f * (1 - t) * t * bPoints.cp1.y + t * t * bPoints.ep.y, deviceSize);
				vertices[i * 3 + 2] = DEFAULT_DEPTH;
				t += 1.0f / segments;
			}			
		} else {
			for (int i = 0; i < segments; i++) {
				vertices[i * 3] = CG_X_TO_GL(powf(1 - t, 3) * bPoints.sp.x 
									+ 3.0f * powf(1 - t, 2) * t * bPoints.cp1.x
									+ 3.0f * (1 - t) * t * t * bPoints.cp2.x 
									+ t * t * t * bPoints.ep.x, deviceSize);
				vertices[i * 3 + 1] = CG_Y_TO_GL(powf(1 - t, 3) * bPoints.sp.y 
										+ 3.0f * powf(1 - t, 2) * t * bPoints.cp1.y
										+ 3.0f * (1 - t) * t * t * bPoints.cp2.y 
										+ t * t * t * bPoints.ep.y, deviceSize);
				vertices[i * 3 + 2] = DEFAULT_DEPTH;
				t += 1.0f / segments;
			}
		}
		
		GL_DRAW_ARRAY(context, color, nil, width, vertices, 0, segments, GL_LINE_STRIP);
	}
}

#pragma mark -

- (void)drawRoundRect:(CGRect)rect radius:(CGFloat)radius inContext:(EAGLContext *)context withColor:(UIColor *)color {
	[self drawRoundRect:rect radius:radius inContext:context withColor:color width:DEFAULT_LINE_WIDTH];
}

- (void)drawRoundRect:(CGRect)rect radius:(CGFloat)radius 
			inContext:(EAGLContext *)context 
			withColor:(UIColor *)color width:(CGFloat)width {
	
	radius = MIN(radius, MIN(rect.size.width, rect.size.height) / 2);
	CGFloat xOffset, yOffset;
	GLfloat vertices[3 * 360];
	for (int i = 0; i < 360; i++) {
		switch (i / 90) {
			case 0:
				xOffset = rect.origin.x + rect.size.width - radius * 2;
				yOffset = rect.origin.y + rect.size.height - radius * 2;
				break;
			case 1:
				xOffset = rect.origin.x;
				yOffset = rect.origin.y + rect.size.height - radius * 2;
				break;
			case 2:
				xOffset = rect.origin.x;
				yOffset = rect.origin.y;
				break;
			case 3:
				xOffset = rect.origin.x + rect.size.width - radius * 2;
				yOffset = rect.origin.y;
				break;
		}
		vertices[3 * i + 0] = CG_X_TO_GL(radius + radius * cos(DEGREES_TO_RADIANS(i)) + xOffset, deviceSize);
		vertices[3 * i + 1] = CG_Y_TO_GL(radius + radius * sin(DEGREES_TO_RADIANS(i)) + yOffset, deviceSize);
		vertices[3 * i + 2] = DEFAULT_DEPTH;		
	}
	
	GL_DRAW_ARRAY(context, color, nil, width, vertices, 0, 360, GL_LINE_LOOP);
}

- (void)fillRoundRect:(CGRect)rect radius:(CGFloat)radius 
			inContext:(EAGLContext *)context 
			withColor:(UIColor *)color gradient:(const GLfloat *)glColors {
	
	radius = MIN(radius, MIN(rect.size.width, rect.size.height) / 2);
	CGFloat xOffset, yOffset;
	GLfloat vertices[3 * 360];
	for (int i = 0; i < 360; i++) {
		switch (i / 90) {
			case 0:
				xOffset = rect.origin.x + rect.size.width - radius * 2;
				yOffset = rect.origin.y + rect.size.height - radius * 2;
				break;
			case 1:
				xOffset = rect.origin.x;
				yOffset = rect.origin.y + rect.size.height - radius * 2;
				break;
			case 2:
				xOffset = rect.origin.x;
				yOffset = rect.origin.y;
				break;
			case 3:
				xOffset = rect.origin.x + rect.size.width - radius * 2;
				yOffset = rect.origin.y;
				break;
		}
		vertices[3 * i + 0] = CG_X_TO_GL(radius + radius * cos(DEGREES_TO_RADIANS(i)) + xOffset, deviceSize);
		vertices[3 * i + 1] = CG_Y_TO_GL(radius + radius * sin(DEGREES_TO_RADIANS(i)) + yOffset, deviceSize);
		vertices[3 * i + 2] = DEFAULT_DEPTH;		
	}
	
	GL_DRAW_ARRAY(context, color, glColors, DEFAULT_LINE_WIDTH, vertices, 0, 360, GL_TRIANGLE_FAN);
}

#pragma mark -

- (void)drawPolygonByPoints:(CGPoint *)points pointAmount:(NSInteger)count 
				  inContext:(EAGLContext *)context 
				  withColor:(UIColor *)color {
	
	[self drawPolygonByPoints:points pointAmount:count inContext:context withColor:color width:DEFAULT_LINE_WIDTH];
}

- (void)drawPolygonByPoints:(CGPoint *)points pointAmount:(NSInteger)count 
				  inContext:(EAGLContext *)context 
				  withColor:(UIColor *)color width:(CGFloat)width {
	
	if (count < 2) {
		LOG_INFO(@"draw polygon with less than 2 point", self);
		return;
	}
	
	GLfloat vertices[3 * count];
	for (int i = 0; i < count; i++) {
		vertices[3 * i + 0] = CG_X_TO_GL(points[i].x, deviceSize);
		vertices[3 * i + 1] = CG_Y_TO_GL(points[i].y, deviceSize);
		vertices[3 * i + 2] = DEFAULT_DEPTH;
	}
	
	GL_DRAW_ARRAY(context, color, nil, width, vertices, 0, count, GL_LINE_LOOP);
}

- (void)fillPolygonByPoints:(CGPoint *)points pointAmount:(NSInteger)count 
				  inContext:(EAGLContext *)context 
				  withColor:(UIColor *)color gradient:(const GLfloat *)glColors {
	
	if (count < 2) {
		LOG_INFO(@"fill polygon with less than 2 point", self);
		return;
	}
	
	GLfloat vertices[3 * count];
	for (int i = 0; i < count; i++) {
		vertices[3 * i + 0] = CG_X_TO_GL(points[i].x, deviceSize);
		vertices[3 * i + 1] = CG_Y_TO_GL(points[i].y, deviceSize);
		vertices[3 * i + 2] = DEFAULT_DEPTH;
	}
	
	GL_DRAW_ARRAY(context, color, glColors, DEFAULT_LINE_WIDTH, vertices, 0, count, GL_TRIANGLE_FAN);
}

- (void)drawRegularPolygon:(NSInteger)sideAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
				 inContext:(EAGLContext *)context 
				 withColor:(UIColor *)color {
	
	[self drawRegularPolygon:sideAmount at:center radius:radius angle:angle 
				   inContext:context 
				   withColor:color width:DEFAULT_LINE_WIDTH];
}

- (void)drawRegularPolygon:(NSInteger)sideAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
				 inContext:(EAGLContext *)context 
				 withColor:(UIColor *)color width:(CGFloat)width {
	
	if (sideAmount < 3) {
		LOG_INFO(@"dra regular polygon with less than 3 point", self);
		return;
	}
	
	GLfloat vertices[3 * sideAmount];
	CGFloat radians = DEGREES_TO_RADIANS(angle);
	CGFloat x, y;
	for (int i = 0; i < sideAmount; i++) {
		x = center.x - radius * sin(radians);
		y = center.y - radius * cos(radians);
		radians += 2 * M_PI / sideAmount;
		
		vertices[3 * i + 0] = CG_X_TO_GL(x, deviceSize);
		vertices[3 * i + 1] = CG_Y_TO_GL(y, deviceSize);
		vertices[3 * i + 2] = DEFAULT_DEPTH;
	}
	
	GL_DRAW_ARRAY(context, color, nil, width, vertices, 0, sideAmount, GL_LINE_LOOP);
}

- (void)fillRegularPolygon:(NSInteger)sideAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
				 inContext:(EAGLContext *)context 
				 withColor:(UIColor *)color gradient:(const GLfloat *)glColors {
	
	if (sideAmount < 3) {
		LOG_INFO(@"dra regular polygon with less than 3 point", self);
		return;
	}
	
	GLfloat vertices[3 * sideAmount];
	CGFloat radians = DEGREES_TO_RADIANS(angle);
	CGFloat x, y;
	for (int i = 0; i < sideAmount; i++) {
		x = center.x - radius * sin(radians);
		y = center.y - radius * cos(radians);
		radians += 2 * M_PI / sideAmount;
		
		vertices[3 * i + 0] = CG_X_TO_GL(x, deviceSize);
		vertices[3 * i + 1] = CG_Y_TO_GL(y, deviceSize);
		vertices[3 * i + 2] = DEFAULT_DEPTH;
	}
	
	GL_DRAW_ARRAY(context, color, glColors, DEFAULT_LINE_WIDTH, vertices, 0, sideAmount, GL_TRIANGLE_FAN);
}

#pragma mark -

- (void)drawStar:(NSInteger)pointAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
	   inContext:(EAGLContext *)context 
	   withColor:(UIColor *)color {
	
	[self drawStar:pointAmount at:center radius:radius angle:angle inContext:context withColor:color width:DEFAULT_LINE_WIDTH];
}

- (void)drawStar:(NSInteger)pointAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
	   inContext:(EAGLContext *)context 
	   withColor:(UIColor *)color width:(CGFloat)width {
	
	if (pointAmount < 3) {
		LOG_INFO(@"dra regular polygon with less than 3 point", self);
		return;
	}
	
	if (pointAmount % 2 == 0) {
		if (pointAmount == 4) {
			[self drawRegularPolygon:pointAmount at:center radius:radius angle:angle 
						   inContext:context 
						   withColor:color width:width];
		} else {
			[self drawStar:(pointAmount / 2) at:center radius:radius angle:angle 
				 inContext:context 
				 withColor:color width:width];
			[self drawStar:(pointAmount / 2) at:center radius:radius angle:(angle + 360 / pointAmount) 
				 inContext:context 
				 withColor:color width:width];
		}
		return;
	}
	
	GLfloat vertices[3 * pointAmount];
	CGFloat radians = DEGREES_TO_RADIANS(angle);
	CGFloat x, y;
	for (int i = 0; i < pointAmount; i++) {
		x = center.x - radius * sin(radians);
		y = center.y - radius * cos(radians);
		radians +=  2 * 2 * M_PI / pointAmount;
		
		vertices[3 * i + 0] = CG_X_TO_GL(x, deviceSize);
		vertices[3 * i + 1] = CG_Y_TO_GL(y, deviceSize);
		vertices[3 * i + 2] = DEFAULT_DEPTH;
	}
	
	GL_DRAW_ARRAY(context, color, nil, width, vertices, 0, pointAmount, GL_LINE_LOOP);	
}

- (void)fillStar:(NSInteger)pointAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
	   inContext:(EAGLContext *)context 
	   withColor:(UIColor *)color gradient:(const GLfloat *)glColors {
	
	if (pointAmount < 3) {
		LOG_INFO(@"dra regular polygon with less than 3 point", self);
		return;
	}
	
	if (pointAmount % 2 == 0) {
		if (pointAmount == 4) {
			[self fillRegularPolygon:pointAmount at:center radius:radius angle:angle 
						   inContext:context 
						   withColor:color gradient:glColors];
		} else {
			[self fillStar:(pointAmount / 2) at:center radius:radius angle:angle 
				 inContext:context 
				 withColor:color gradient:glColors];
			[self fillStar:(pointAmount / 2) at:center radius:radius angle:(angle + 360 / pointAmount) 
				 inContext:context 
				 withColor:color gradient:glColors];
		}
		return;
	}
	
	GLfloat vertices[3 * (pointAmount + 2)];
	CGFloat radians = DEGREES_TO_RADIANS(angle);
	CGFloat x, y;
	for (int i = 0; i < pointAmount; i++) {
		x = center.x - radius * sin(radians);
		y = center.y - radius * cos(radians);
		radians +=  2 * 2 * M_PI / pointAmount;
		
		vertices[3 * i + 0] = CG_X_TO_GL(x, deviceSize);
		vertices[3 * i + 1] = CG_Y_TO_GL(y, deviceSize);
		vertices[3 * i + 2] = DEFAULT_DEPTH;
		
		if (i == 0) {
			vertices[3 * pointAmount + 0] = CG_X_TO_GL(x, deviceSize);
			vertices[3 * pointAmount + 1] = CG_Y_TO_GL(y, deviceSize);
			vertices[3 * pointAmount + 2] = DEFAULT_DEPTH;
		} else if (i == 1) {
			vertices[3 * pointAmount + 3] = CG_X_TO_GL(x, deviceSize);
			vertices[3 * pointAmount + 4] = CG_Y_TO_GL(y, deviceSize);
			vertices[3 * pointAmount + 5] = DEFAULT_DEPTH;
		}
	}
	/* FIXME: fill star */
	GL_DRAW_ARRAY(context, color, glColors, DEFAULT_LINE_WIDTH, vertices, 0, pointAmount + 2, GL_TRIANGLE_STRIP);
}

#pragma mark -

- (void)drawFanAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise 
		inContext:(EAGLContext *)context 
		withColor:(UIColor *)color {
	
	[self drawFanAt:center radius:radius 
			   from:startAngle to:endAngle clockwise:clockwise 
		  inContext:context 
		  withColor:color width:DEFAULT_LINE_WIDTH];
}

- (void)drawFanAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise 
		inContext:(EAGLContext *)context 
		withColor:(UIColor *)color width:(CGFloat)width {
	
	if (clockwise == kArcCounterClockwise) {
		SWAP(startAngle, endAngle);
	}
	NSInteger count = (NSInteger)(endAngle - startAngle + 360) % 360;
	GLfloat vertices[6 * (count - 1) + 3];
	vertices[0] = CG_X_TO_GL(center.x, deviceSize);
	vertices[1] = CG_Y_TO_GL(center.y, deviceSize);
	vertices[2] = DEFAULT_DEPTH;
	for (int i = 0; i < count - 1; i++) {
		vertices[6 * i + 3] = CG_X_TO_GL(center.x + radius * cos(DEGREES_TO_RADIANS(i + startAngle)), deviceSize);
		vertices[6 * i + 4] = CG_Y_TO_GL(center.y + radius * sin(DEGREES_TO_RADIANS(i + startAngle)), deviceSize);
		vertices[6 * i + 5] = DEFAULT_DEPTH;
		vertices[6 * i + 6] = CG_X_TO_GL(center.x + radius * cos(DEGREES_TO_RADIANS(i + startAngle + 1)), deviceSize);
		vertices[6 * i + 7] = CG_Y_TO_GL(center.y + radius * sin(DEGREES_TO_RADIANS(i + startAngle + 1)), deviceSize);
		vertices[6 * i + 8] = DEFAULT_DEPTH;
	}
	
	GL_DRAW_ARRAY(context, color, nil, width, vertices, 0, 2 * (count - 1) + 1, GL_LINE_LOOP);
}

- (void)fillFanAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise 
		inContext:(EAGLContext *)context 
		withColor:(UIColor *)color gradient:(const GLfloat *)glColors {
	
	if (clockwise == kArcCounterClockwise) {
		SWAP(startAngle, endAngle);
	}
	NSInteger count = (NSInteger)(endAngle - startAngle + 360) % 360;
	GLfloat vertices[6 * (count - 1) + 3];
	vertices[0] = CG_X_TO_GL(center.x, deviceSize);
	vertices[1] = CG_Y_TO_GL(center.y, deviceSize);
	vertices[2] = DEFAULT_DEPTH;
	for (int i = 0; i < count - 1; i++) {
		vertices[6 * i + 3] = CG_X_TO_GL(center.x + radius * cos(DEGREES_TO_RADIANS(i + startAngle)), deviceSize);
		vertices[6 * i + 4] = CG_Y_TO_GL(center.y + radius * sin(DEGREES_TO_RADIANS(i + startAngle)), deviceSize);
		vertices[6 * i + 5] = DEFAULT_DEPTH;
		vertices[6 * i + 6] = CG_X_TO_GL(center.x + radius * cos(DEGREES_TO_RADIANS(i + startAngle + 1)), deviceSize);
		vertices[6 * i + 7] = CG_Y_TO_GL(center.y + radius * sin(DEGREES_TO_RADIANS(i + startAngle + 1)), deviceSize);
		vertices[6 * i + 8] = DEFAULT_DEPTH;
	}
	
	GL_DRAW_ARRAY(context, color, glColors, DEFAULT_LINE_WIDTH, vertices, 0, 2 * (count - 1) + 1, GL_TRIANGLE_FAN);
}

#pragma mark -

- (void)getTextureByImage:(UIImage *)image orName:(NSString *)name {
	if (!texturesArray) {
		texturesArray = [[NSMutableArray alloc] initWithCapacity:0];
	}
	currTexture = nextTexture;
	if (name) {
		for (int i = 0; i < MAX_TEXTURE; i++) {
			if ([texturesArray count] <= i) {
				break;
			}
			NSString * texName = (NSString *)[texturesArray objectAtIndex:(i)];
			if ([texName compare:name] == 0) {
				currTexture = i;
				break;
			}
		}
	} else {
		// TODO: get image
	}	
	
	if (!textures[currTexture]) {
		glGenTextures(1, &textures[currTexture]);
		glBindTexture(GL_TEXTURE_2D, textures[currTexture]);
		textureSize[currTexture] = [self loadTextureWithImage:image orName:name];
		if (name) {
			[texturesArray addObject:name];
		} else {
			[texturesArray addObject:image];
		}
		nextTexture++;
	}	
}

- (void)drawImage:(UIImage *)image at:(CGPoint)position inContext:(EAGLContext *)context {
	[self drawImage:image at:position alignment:DEFAULT_ALIGNMENT 
		  inContext:context 
		  withTrans:1 flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
}

- (void)drawImage:(UIImage *)image at:(CGPoint)position inContext:(EAGLContext *)context withTrans:(CGFloat)alpha {
	[self drawImage:image at:position alignment:DEFAULT_ALIGNMENT
		  inContext:context 
		  withTrans:alpha flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
}

- (void)drawImage:(UIImage *)image at:(CGPoint)position alignment:(kDrawStyle)alignment inContext:(EAGLContext *)context {
	[self drawImage:image at:position alignment:alignment 
		  inContext:context 
		  withTrans:1 flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
}

- (void)drawImage:(UIImage *)image at:(CGPoint)position alignment:(kDrawStyle)alignment
		inContext:(EAGLContext *)context
		withTrans:(CGFloat)alpha {
	[self drawImage:image at:position alignment:alignment
		  inContext:context 
		  withTrans:alpha flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
}

- (void)drawImage:(UIImage *)image at:(CGPoint)position alignment:(kDrawStyle)alignment 
		inContext:(EAGLContext *)context 
		withTrans:(CGFloat)alpha flip:(kDrawStyle)flip rotate:(CGFloat)angle scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY {
	
	[self getTextureByImage:image orName:nil];
	CGRect imgRect = CGRectMake(position.x, position.y, textureSize[currTexture].width, textureSize[currTexture].height);
	if (alignment == kAlignmentHcenterTop || alignment == kAlignmentHcenterVcenter || alignment == kAlignmentHcenterBottom) {
		imgRect.origin.x -= imgRect.size.width / 2;
		imgRect.origin.x += imgRect.size.width * (1 - scaleX) / 2;
		imgRect.size.width *= scaleX;
	}
	if (alignment == kAlignmentRightTop || alignment == kAlignmentRightVcenter || alignment == kAlignmentRightBottom) {
		imgRect.origin.x -= imgRect.size.width;
		imgRect.origin.x += imgRect.size.width * (1 - scaleX);
		imgRect.size.width *= scaleX;
	}
	if (alignment == kAlignmentLeftVcenter || alignment == kAlignmentHcenterVcenter || alignment == kAlignmentRightVcenter) {
		imgRect.origin.y -= imgRect.size.height / 2;
		imgRect.origin.y += imgRect.size.height * (1 - scaleX) / 2;
		imgRect.size.height *= scaleY;
	}
	if (alignment == kAlignmentLeftBottom || alignment == kAlignmentHcenterBottom || alignment == kAlignmentRightBottom) {
		imgRect.origin.y -= imgRect.size.height;
		imgRect.origin.y += imgRect.size.height * (1 - scaleX);
		imgRect.size.height *= scaleY;
	}
	if (alignment == kAlignmentLeftTop) {
		imgRect.size.width *= scaleX;
		imgRect.size.height *= scaleY;
	}
	
	[self drawTexture:textures[currTexture] inRect:imgRect inContext:context withTrans:alpha flip:flip rotate:angle];
}

- (void)drawImageNamed:(NSString *)name at:(CGPoint)position inContext:(EAGLContext *)context {
	[self drawImageNamed:name at:position alignment:DEFAULT_ALIGNMENT
			   inContext:context 
			   withTrans:1 flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
}

- (void)drawImageNamed:(NSString *)name at:(CGPoint)position inContext:(EAGLContext *)context withTrans:(CGFloat)alpha {
	[self drawImageNamed:name at:position alignment:DEFAULT_ALIGNMENT
			   inContext:context 
			   withTrans:alpha flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
}

- (void)drawImageNamed:(NSString *)name at:(CGPoint)position alignment:(kDrawStyle)alignment inContext:(EAGLContext *)context {
	[self drawImageNamed:name at:position alignment:alignment
			   inContext:context 
			   withTrans:1 flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
}

- (void)drawImageNamed:(NSString *)name at:(CGPoint)position alignment:(kDrawStyle)alignment
			 inContext:(EAGLContext *)context 
			 withTrans:(CGFloat)alpha {
	[self drawImageNamed:name at:position alignment:alignment
			   inContext:context 
			   withTrans:alpha flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
}

- (void)drawImageNamed:(NSString *)name at:(CGPoint)position alignment:(kDrawStyle)alignment 
			 inContext:(EAGLContext *)context 
			 withTrans:(CGFloat)alpha flip:(kDrawStyle)flip rotate:(CGFloat)angle scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY {
	
	[self getTextureByImage:nil orName:name];
	CGRect imgRect = CGRectMake(position.x, position.y, textureSize[currTexture].width, textureSize[currTexture].height);
	if (alignment == kAlignmentHcenterTop || alignment == kAlignmentHcenterVcenter || alignment == kAlignmentHcenterBottom) {
		imgRect.origin.x -= imgRect.size.width / 2;
		imgRect.origin.x += imgRect.size.width * (1 - scaleX) / 2;
		imgRect.size.width *= scaleX;
	}
	if (alignment == kAlignmentRightTop || alignment == kAlignmentRightVcenter || alignment == kAlignmentRightBottom) {
		imgRect.origin.x -= imgRect.size.width;
		imgRect.origin.x += imgRect.size.width * (1 - scaleX);
		imgRect.size.width *= scaleX;
	}
	if (alignment == kAlignmentLeftVcenter || alignment == kAlignmentHcenterVcenter || alignment == kAlignmentRightVcenter) {
		imgRect.origin.y -= imgRect.size.height / 2;
		imgRect.origin.y += imgRect.size.height * (1 - scaleX) / 2;
		imgRect.size.height *= scaleY;
	}
	if (alignment == kAlignmentLeftBottom || alignment == kAlignmentHcenterBottom || alignment == kAlignmentRightBottom) {
		imgRect.origin.y -= imgRect.size.height;
		imgRect.origin.y += imgRect.size.height * (1 - scaleX);
		imgRect.size.height *= scaleY;
	}
	if (alignment == kAlignmentLeftTop) {
		imgRect.size.width *= scaleX;
		imgRect.size.height *= scaleY;
	}
	
	[self drawTexture:textures[currTexture] inRect:imgRect inContext:context withTrans:alpha flip:flip rotate:angle];
}

- (void)fillImage:(UIImage *)image inRect:(CGRect)rect inContext:(EAGLContext *)context {
	[self fillImage:image inRect:rect inContext:context withTrans:1 flip:kFlipNone rotate:0];
}

- (void)fillImage:(UIImage *)image inRect:(CGRect)rect inContext:(EAGLContext *)context withTrans:(CGFloat)alpha {
	[self fillImage:image inRect:rect inContext:context withTrans:alpha flip:kFlipNone rotate:0];
}

- (void)fillImage:(UIImage *)image inRect:(CGRect)rect 
		inContext:(EAGLContext *)context 
		withTrans:(CGFloat)alpha flip:(kDrawStyle)flip rotate:(CGFloat)angle {
	
	[self getTextureByImage:image orName:nil];
	[self drawTexture:textures[currTexture] inRect:rect inContext:context withTrans:alpha flip:flip rotate:angle];
}

- (void)fillImageNamed:(NSString *)name inRect:(CGRect)rect inContext:(EAGLContext *)context {
	[self fillImageNamed:name inRect:rect inContext:context withTrans:1 flip:kFlipNone rotate:0];
}

- (void)fillImageNamed:(NSString *)name inRect:(CGRect)rect
			 inContext:(EAGLContext *)context 
			 withTrans:(CGFloat)alpha {
	[self fillImageNamed:name inRect:rect inContext:context withTrans:alpha flip:kFlipNone rotate:0];
}

- (void)fillImageNamed:(NSString *)name inRect:(CGRect)rect
			 inContext:(EAGLContext *)context
			 withTrans:(CGFloat)alpha flip:(kDrawStyle)flip rotate:(CGFloat)angle {
	
	[self getTextureByImage:nil orName:name];
	[self drawTexture:textures[currTexture] inRect:rect inContext:context withTrans:alpha flip:flip rotate:angle];
}

- (void)drawTexture:(GLuint)texture inRect:(CGRect)rect
		  inContext:(EAGLContext *)context 
		  withTrans:(CGFloat)alpha flip:(kDrawStyle)flip rotate:(CGFloat)angle {

	GL_EXCEPTION(context);
	glPushMatrix();
	{
		GLfloat vertices[] = {
			CG_X_TO_GL(rect.origin.x, deviceSize),
			CG_Y_TO_GL(rect.origin.y, deviceSize),
			DEFAULT_DEPTH,
			
			CG_X_TO_GL(rect.origin.x + rect.size.width, deviceSize),
			CG_Y_TO_GL(rect.origin.y, deviceSize),
			DEFAULT_DEPTH,
			
			CG_X_TO_GL(rect.origin.x, deviceSize),
			CG_Y_TO_GL(rect.origin.y + rect.size.height, deviceSize),
			DEFAULT_DEPTH,
			
			CG_X_TO_GL(rect.origin.x + rect.size.width, deviceSize),
			CG_Y_TO_GL(rect.origin.y + rect.size.height, deviceSize),
			DEFAULT_DEPTH
		};
		
		const GLfloat texcoords[] = {
			0.0,		0.0,
			1.0,		0.0,
			0.0,		1.0,
			1.0,		1.0
		};
		
		glColor4f(1, 1, 1, alpha);
		glBindTexture(GL_TEXTURE_2D, texture);
		glEnable(GL_TEXTURE_2D);
		
		/* FIXME: flip in rect */
		if (flip == kFlipX || flip == kFlipXY) {
			glScalef(-1, 1, 1);
		}
		if (flip != kFlipY && flip != kFlipXY) {
			glScalef(1, -1, 1);
		}
		
		/* FIXME: angle in rect */
		glRotatef(angle, 0, 0, 1);
		
		glVertexPointer(3, GL_FLOAT, 0, vertices);
		glEnableClientState(GL_VERTEX_ARRAY);
		glTexCoordPointer(2, GL_FLOAT, 0, texcoords);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glBindTexture(GL_TEXTURE_2D, 0);
	}
	glPopMatrix();	
}

- (void)drawTexture:(GLuint)texture at:(CGPoint)center 
	   inContextext:(EAGLContext *)context 
			   from:(CGFloat)startAngle to:(CGFloat)endAngle {
	
	GL_EXCEPTION(context);
	glPushMatrix();
	{
		GLfloat texcoordsAll[] = {
			0.5, 0.5,
			0.5, 0,
			0, 0,
			0, 0.5,
			0, 1,
			0.5, 1,
			1, 1,
			1, 0.5,
			1, 0
		};
		
		
		NSInteger verticeCount = (360 - startAngle) / 45 + 2;		
		GLfloat vertices[2 * (verticeCount + 1)];
		GLfloat texcoords[2 * (verticeCount + 1)];
		
		for (int i = 0; i < 2 * verticeCount; i++) {
			texcoords[i] = texcoordsAll[i];
			if (i % 2 == 0) {
				vertices[i] = TEX_X_TO_VER(texcoords[i], deviceSize);
			} else {
				vertices[i] = TEX_Y_TO_VER(texcoords[i], deviceSize);
			}
		}
		
		if ((NSInteger)startAngle % 45 != 0) {
			GLfloat xStart, yStart;
			
			if (VALUE_BETWEEN(startAngle, 45, 135) || VALUE_BETWEEN(startAngle, 225, 325)) {
				xStart = 1 - (int)startAngle / 180;
				float tanValue = tan(DEGREES_TO_RADIANS(startAngle));
				yStart = 0.5 - (xStart - 0.5) / tanValue;
			} else {
				yStart = VALUE_BETWEEN(startAngle, 90, 270) ? 1 : 0;
				float tanValue = tan(DEGREES_TO_RADIANS(startAngle));
				xStart = 0.5 + (0.5 - yStart) * tanValue;
			}
			
			CLAMP(xStart, 0, 1);
			CLAMP(yStart, 0, 1);
			
			texcoords[2 * verticeCount] = xStart;
			vertices[2 * verticeCount] = TEX_X_TO_VER(xStart, deviceSize);
			texcoords[2 * verticeCount + 1] = yStart;
			vertices[2 * verticeCount + 1] = TEX_Y_TO_VER(yStart, deviceSize);
			
			verticeCount += 1;
		}
		
		glColor4f(1, 1, 1, 1);
		glBindTexture(GL_TEXTURE_2D, texture);
		glEnable(GL_TEXTURE_2D);
		
		glScalef(1, -1, 1);
		glTranslatef(CG_X_TO_GL(center.x, deviceSize) , CG_Y_TO_GL(center.y, deviceSize), 0);
		
		glVertexPointer(2, GL_FLOAT, 0, vertices);
		glEnableClientState(GL_VERTEX_ARRAY);
		glTexCoordPointer(2, GL_FLOAT, 0, texcoords);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		
		glDrawArrays(GL_TRIANGLE_FAN, 0, verticeCount);		
	}
	glPopMatrix();
}

@end
