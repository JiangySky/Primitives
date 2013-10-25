    //
//  PrimitiveView.m
//  PrimitivesDemo
//
//  Created by Jiangy on 11-5-14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PrimitiveView.h"
#import "PrimitiveController.h"

@implementation PrimitiveView

@synthesize primitiveQZ;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (void)initWithController:(PrimitiveController *)controller {
	ctrl = controller;
	
	if (!primitiveQZ) {
		primitiveQZ = [[PrimitivesQZ alloc] init];
	}
	
	UILongPressGestureRecognizer * press = [[UILongPressGestureRecognizer alloc] initWithTarget:ctrl action:@selector(longPress:)];
	[press setMinimumPressDuration:1.0f];
	[self addGestureRecognizer:press];
	[press release];
	
	UIPinchGestureRecognizer * pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:ctrl action:@selector(pinch:)];
	[self addGestureRecognizer:pinch];
	[pinch release];
}

- (void)dealloc {
	[primitiveQZ release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {
	[self drawInContext:UIGraphicsGetCurrentContext()];
}

#pragma mark -

- (void)setupView {
	
}

- (void)drawInContext:(CGContextRef)context {
	[primitiveQZ cleanScreenInContext:context];
	
	// MARK: set some args here
	float width = DEFAULT_LINE_WIDTH;
	float radius = 30;
	const CGPoint pointCenter = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
	
	UIColor * color = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
	
	UIColor * color0 = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
	UIColor * color1 = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
	UIColor * color2 = [UIColor colorWithRed:0 green:0 blue:1 alpha:1];
	UIColor * color3 = [UIColor colorWithRed:0 green:1 blue:1 alpha:1];
	UIColor * color4 = [UIColor colorWithRed:1 green:0 blue:1 alpha:1];
	UIColor * color5 = [UIColor colorWithRed:1 green:1 blue:0 alpha:1];
	
	UIColor * colorsUI[] = {
		color0, color1, color2, color3
	};
	
	CGFloat colorsGL[] = {
        1.0, 0.0, 0.0, 1.0,		// Red - top left - colour for squareVertices[0]
        0.0, 1.0, 0.0, 1.0,		// Green - bottom left - squareVertices[1]
        0.0, 0.0, 1.0, 1.0,		// Blue - bottom right - squareVerticies[2]
        0.5, 0.5, 0.5, 1.0		// Grey - top right- squareVerticies[3]
    };
	
	CGPoint pointStart = CGPointMake(100, 100);
	CGPoint pointEnd = CGPointMake(200, 100);	
	
	CGPoint point0 = CGPointMake(160, 120);
	CGPoint point1 = CGPointMake(80, 240);
	CGPoint point2 = CGPointMake(160, 360);
	CGPoint point3 = CGPointMake(240, 240);
	CGPoint point4 = CGPointZero;
	CGPoint point5 = CGPointZero;
	
	CGPoint points[] = {
		CGPointMake(pointCenter.x - 80, pointCenter.y - 80),
		CGPointMake(pointCenter.x + 80, pointCenter.y - 80),
		CGPointMake(pointCenter.x + 80, pointCenter.y + 80),
		CGPointMake(pointCenter.x - 80, pointCenter.y + 80),
		CGPointZero,
		CGPointZero,
	};
	
	CGRect rect = CGRectMake(100, 50, 100, 80);
	
	CGRect rect0 = CGRectMake(10, 220, 50, 50);
	CGRect rect1 = CGRectMake(70, 180, 50, 50);
	CGRect rect2 = CGRectMake(130, 220, 50, 50);
	CGRect rect3 = CGRectMake(190, 180, 50, 50);
	
	CGRect rects[] = {
		CGRectMake(20, 300, 50, 80),
		CGRectMake(95, 300, 50, 80),
		CGRectMake(170, 300, 50, 80),
		CGRectMake(240, 300, 50, 80)
	};
	
	if (CGPointEqualToPoint(CGPointZero, ctrl.pointTouchBegin)) {
		ctrl.pointTouchBegin = pointCenter;
	}
	if (CGPointEqualToPoint(CGPointZero, ctrl.pointTouchEnd)) {
		ctrl.pointTouchEnd = pointCenter;
	}
	
	CGGlyph glyphs[32];
	
	switch (ctrl.priType) {
		case kPrimitivePoint: {
			// MARK: point
			for (int i = 0; i < 4; i++) {
				[primitiveQZ drawPoint:points[i] inContext:context 
						   withColor:[UIColor colorWithRed:colorsGL[4*i] 
													 green:colorsGL[4*i+1] 
													  blue:colorsGL[4*i+2] 
													 alpha:colorsGL[4*i+3]]];
			}
			[primitiveQZ drawPoint:ctrl.pointTouchBegin inContext:context withColor:USER_COLOR width:ctrl.lineWidth];
			break;
		}
		case kPrimitiveLine: {
			// MARK: line
			width = 5;
			color = color0;
			pointStart = CGPointMake(10, 160);
			pointEnd = CGPointMake(110, 260);
			[primitiveQZ drawLineFrom:pointStart to:pointEnd 
						  inContext:context 
						  withColor:color width:width 
					  solidOrDotted:kLineSolid];
			
			color = color4;
			pointStart = CGPointMake(110, 160);
			pointEnd = CGPointMake(210, 260);
			[primitiveQZ drawLineFrom:pointStart to:pointEnd 
						  inContext:context 
						  withColor:color width:width 
					  solidOrDotted:kLineDotted];
			
			color = color3;
			pointStart = CGPointMake(210, 160);
			pointEnd = CGPointMake(310, 260);
			[primitiveQZ drawLineFrom:pointStart to:pointEnd 
						  inContext:context 
						  withColor:color width:width cap:kCGLineJoinRound join:kCGLineJoinRound
					  solidOrDotted:kLineDotted];
			
			// draw lines
			width = 2;
			color = color1;
			points[0] = CGPointMake(10.0, 90.0);
			points[1] = CGPointMake(70.0, 60.0);
			points[2] = CGPointMake(130.0, 90.0);
			points[3] = CGPointMake(190.0, 60.0);
			points[4] = CGPointMake(250.0, 90.0);
			points[5] = CGPointMake(310.0, 60.0);
			[primitiveQZ drawLines:points pointAmount:ARRAY_LENGTH(points) 
					   inContext:context 
					   withColor:color width:width cap:kCGLineJoinRound join:kCGLineJoinRound
				   solidOrDotted:kLineSolid 
					   joinOrSeg:kLineSegments];
			
			// draw lines ...
			width = 2;
			color = color2;
			point0 = CGPointMake(10.0, 150.0);
			point1 = CGPointMake(70.0, 100.0);
			point2 = CGPointMake(130.0, 150.0);
			point3 = CGPointMake(190.0, 100.0);
			point4 = CGPointMake(250.0, 150.0);
			point5 = CGPointMake(310.0, 100.0);	
			[primitiveQZ drawLinesInContext:context 
									 withColor:color width:width 
								 solidOrDotted:kLineDotted 
									 joinOrSeg:kLineJoin  
									   sPoints:sPoint(point0), sPoint(point1), sPoint(point2), 
												sPoint(point3), sPoint(point4), sPoint(point5), nil];
			
			[primitiveQZ drawLineFrom:ctrl.pointTouchBegin to:ctrl.pointTouchEnd 
						  inContext:context 
						  withColor:USER_COLOR width:DEFAULT_LINE_WIDTH 
					  solidOrDotted:kLineSolid];
			
			break;
		}
		case kPrimitiveArc: {
			// MARK: arc
			width = 5;
			color = color0;
			[primitiveQZ drawPoint:pointCenter inContext:context withColor:color width:width];
			[primitiveQZ drawLineFrom:pointCenter to:CGPointMake(pointCenter.x + 50, pointCenter.y) 
						  inContext:context withColor:color width:DEFAULT_LINE_WIDTH
					  solidOrDotted:kLineDotted];
			width = 2;
			color = color1;
			[primitiveQZ drawArcAt:pointCenter radius:50 from:-90 to:90 clockwise:kArcClockwise inContext:context withColor:color];
			color = color2;
			[primitiveQZ drawArcAt:pointCenter radius:50 from:-90 to:90 clockwise:kArcCounterClockwise 
					   inContext:context 
					   withColor:color width:width 
				   solidOrDotted:kLineDotted];
			width = 4;
			color = color3;
			[primitiveQZ drawArcAt:pointCenter radius:80 from:135 to:225 clockwise:kArcClockwise 
					   inContext:context 
					   withColor:color width:width cap:kCGLineJoinRound join:kCGLineJoinRound
				   solidOrDotted:kLineDotted];
			
			pointStart = CGPointMake(150, 50);
			pointEnd = CGPointMake(250, 150);
			width = 5;
			color = color0;
			[primitiveQZ drawPoint:pointStart inContext:context withColor:color width:width];
			[primitiveQZ drawPoint:pointEnd inContext:context withColor:color width:width];
			[primitiveQZ drawLineFrom:pointStart to:pointEnd
						  inContext:context withColor:color width:DEFAULT_LINE_WIDTH
					  solidOrDotted:kLineDotted];
			width = 2;
			color = color1;
			[primitiveQZ drawArcFrom:pointStart to:pointEnd radius:80 clockwise:kArcClockwise inContext:context withColor:color];
			color = color2;
			width = 4;
			[primitiveQZ drawArcFrom:pointStart to:pointEnd radius:80 clockwise:kArcCounterClockwise
						 inContext:context 
						 withColor:color width:width 
					 solidOrDotted:kLineDotted];
			
			if (CGRectContainsPoint(CGRectMake(0, 0, pointCenter.x * 2, pointCenter.y), ctrl.pointTouchBegin)) {
				[primitiveQZ drawPoint:ctrl.pointTouchBegin inContext:context withColor:USER_COLOR width:width];
				[primitiveQZ drawArcAt:ctrl.pointTouchBegin radius:20 + ctrl.lineWidth 
								  from:ctrl.angle to:ctrl.angle + 90 clockwise:kArcClockwise 
						   inContext:context withColor:USER_COLOR];
			} else {
				[primitiveQZ drawPoint:ctrl.pointTouchBegin inContext:context withColor:USER_COLOR width:width];
				[primitiveQZ drawPoint:ctrl.pointTouchEnd inContext:context withColor:USER_COLOR width:width];
				[primitiveQZ drawArcFrom:ctrl.pointTouchBegin to:ctrl.pointTouchEnd 
								radius:DISTANCE_BETWEEN_POINT(ctrl.pointTouchBegin, ctrl.pointTouchEnd) + ctrl.lineWidth 
							   clockwise:kArcClockwise 
							 inContext:context withColor:USER_COLOR];
			}			
			break;
		}
		case kPrimitiveBezier: {
			// MARK: bezier
			width = 5;
			color = color0;
			CGPoint s = CGPointMake(30.0, 120.0);
			CGPoint e = CGPointMake(300.0, 120.0);
			CGPoint c1 = CGPointMake(120.0, 30.0);
			CGPoint c2 = CGPointMake(210.0, 210.0);
			[primitiveQZ drawPoint:s inContext:context withColor:color width:width];
			[primitiveQZ drawPoint:e inContext:context withColor:color width:width];
						
			kBezier bPoints = {s, e, c1, c2};
			color = color1;
			[primitiveQZ drawBezierCurve:bPoints inContext:context withColor:color width:3 solidOrDotted:kLineSolid];
			[primitiveQZ drawPoint:c1 inContext:context withColor:color width:width];
			[primitiveQZ drawPoint:c2 inContext:context withColor:color width:width];
			
			c1 = CGPointMake(10.0, 250.0);			
			kBezier bPoints1 = {s, e, c1, c1};
			color = color2;
			[primitiveQZ drawBezierCurve:bPoints1 inContext:context withColor:color width:3 solidOrDotted:kLineDotted];
			[primitiveQZ drawPoint:c1 inContext:context withColor:color width:width];
			
			s = CGPointMake(pointCenter.x - 120, pointCenter.y + 100);
			e = CGPointMake(pointCenter.x + 120, pointCenter.y + 100);
			c1 = pointCenter;
			c2 = pointCenter;
			if (!CGPointEqualToPoint(ctrl.pointTouchBegin, pointCenter)) {
				c1 = ctrl.pointTouchBegin;
			}
			if (!CGPointEqualToPoint(ctrl.pointTouchEnd, pointCenter)) {
				c2 = ctrl.pointTouchEnd;
			}
			[primitiveQZ drawPoint:s inContext:context withColor:USER_COLOR width:width];
			[primitiveQZ drawPoint:e inContext:context withColor:USER_COLOR width:width];
			[primitiveQZ drawPoint:c1 inContext:context withColor:USER_COLOR width:width];
			[primitiveQZ drawPoint:c2 inContext:context withColor:USER_COLOR width:width];
			kBezier bPoints2 = {s, e, c1, c2};
			[primitiveQZ drawBezierCurve:bPoints2 inContext:context withColor:USER_COLOR];			
			break;
		}
		case kPrimitiveRect: {
			// MARK: rect
			color = color1;
			[primitiveQZ drawRect:rect inContext:context withColor:color];
			width = 4;
			rect.origin.x -= 20;
			rect.origin.y -= 20;
			rect.size.width += 40;
			rect.size.height += 40;
			[primitiveQZ drawRoundRect:rect radius:20 inContext:context withColor:color width:width solidOrDotted:kLineDotted];
			
			rect.origin.x += 40;
			rect.origin.y += 40;
			rect.size.width -= 80;
			rect.size.height -= 80;
			[primitiveQZ fillRoundRect:rect radius:20 inContext:context withColor:color];
			
			color = color2;
			[primitiveQZ drawRects:rects rectAmount:ARRAY_LENGTH(rects) inContext:context 
					   withColor:color width:width solidOrDotted:kLineSolid];
			for (int i = 0; i < ARRAY_LENGTH(rects); i++) {
				rects[i].origin.x += 10;
				rects[i].origin.y += 10;
				rects[i].size.width -= 20;
				rects[i].size.height -= 20;
			}
			[primitiveQZ fillRects:rects rectAmount:ARRAY_LENGTH(rects) inContext:context withColor:color];
			
			color = color3;
			[primitiveQZ drawRectsInContext:context withColor:color width:DEFAULT_LINE_WIDTH solidOrDotted:kLineDotted
								   sRects:sRect(rect0), sRect(rect1), sRect(rect2), sRect(rect3), nil];
			rect0.origin.x += 10;
			rect0.origin.y += 10;
			rect0.size.width -= 20;
			rect0.size.height -= 20;
			rect1.origin.x += 10;
			rect1.origin.y += 10;
			rect1.size.width -= 20;
			rect1.size.height -= 20;
			rect2.origin.x += 10;
			rect2.origin.y += 10;
			rect2.size.width -= 20;
			rect2.size.height -= 20;
			rect3.origin.x += 10;
			rect3.origin.y += 10;
			rect3.size.width -= 20;
			rect3.size.height -= 20;
			[primitiveQZ fillRectsInContext:context withColor:color 
								   sRects:sRect(rect0), sRect(rect1), sRect(rect2), sRect(rect3), nil];
			
			width = 3;
			rect = [ctrl rectByTouchDrag];
			[primitiveQZ drawRect:rect inContext:context withColor:USER_COLOR];
			if (rect.size.width > 30 && rect.size.height > 30) {
				rect.origin.x += 15;
				rect.origin.y += 15;
				rect.size.width -= 30;
				rect.size.height -= 30;				
				[primitiveQZ fillRect:rect inContext:context withColor:USER_COLOR];
			}						
			break;
		}
		case kPrimitiveEllipse: {
			// MARK: ellipse
			color = color1;
			[primitiveQZ drawEllipse:rect inContext:context withColor:color];
			width = 4;
			rect.origin.x -= 20;
			rect.origin.y -= 20;
			rect.size.width += 40;
			rect.size.height += 40;
			[primitiveQZ drawEllipse:rect inContext:context withColor:color width:width solidOrDotted:kLineDotted];
			
			rect.origin.x += 40;
			rect.origin.y += 40;
			rect.size.width -= 80;
			rect.size.height -= 80;
			[primitiveQZ fillEllipse:rect inContext:context withColor:color];
			
			color = color2;
			[primitiveQZ drawEllipses:rects rectAmount:ARRAY_LENGTH(rects) inContext:context 
						  withColor:color width:width solidOrDotted:kLineSolid];
			for (int i = 0; i < ARRAY_LENGTH(rects); i++) {
				rects[i].origin.x += 10;
				rects[i].origin.y += 10;
				rects[i].size.width -= 20;
				rects[i].size.height -= 20;
			}
			[primitiveQZ fillEllipses:rects rectAmount:ARRAY_LENGTH(rects) inContext:context withColor:color];
			
			color = color3;
			[primitiveQZ drawEllipsesInContext:context withColor:color width:DEFAULT_LINE_WIDTH solidOrDotted:kLineDotted
									  sRects:sRect(rect0), sRect(rect1), sRect(rect2), sRect(rect3), nil];
			rect0.origin.x += 10;
			rect0.origin.y += 10;
			rect0.size.width -= 20;
			rect0.size.height -= 20;
			rect1.origin.x += 10;
			rect1.origin.y += 10;
			rect1.size.width -= 20;
			rect1.size.height -= 20;
			rect2.origin.x += 10;
			rect2.origin.y += 10;
			rect2.size.width -= 20;
			rect2.size.height -= 20;
			rect3.origin.x += 10;
			rect3.origin.y += 10;
			rect3.size.width -= 20;
			rect3.size.height -= 20;
			[primitiveQZ fillEllipsesInContext:context withColor:color 
									  sRects:sRect(rect0), sRect(rect1), sRect(rect2), sRect(rect3), nil];
			
			width = 3;
			rect = [ctrl rectByTouchDrag];
			[primitiveQZ drawEllipse:rect inContext:context withColor:USER_COLOR];
			if (rect.size.width > 30 && rect.size.height > 30) {
				rect.origin.x += 15;
				rect.origin.y += 15;
				rect.size.width -= 30;
				rect.size.height -= 30;				
				[primitiveQZ fillEllipse:rect inContext:context withColor:USER_COLOR];
			}						
			break;
		}	
		case kPrimitivePolygon: {
			// MARK: polygon
			color = color2;
			width = 3;
			int y = 10;
			points[0] = CGPointMake(300, y);
			points[1] = CGPointMake(200, y);
			y = 30 + ctrl.angle;
			if (y > 210) {
				y = 420 - y;
			}
			points[2] = CGPointMake(300, y);
			points[5] = CGPointMake(200, y);
			y = 10 + (y - 10) * 2;
			points[4] = CGPointMake(300, y);
			points[3] = CGPointMake(200, y);
			[primitiveQZ fillPolygonByPoints:points pointAmount:ARRAY_LENGTH(points) inContext:context 
								 withColor:color fillColor:color3 width:width cap:kCGLineCapRound join:kCGLineJoinRound 
							 solidOrDotted:kLineDotted pathMode:kCGPathEOFillStroke];
			[primitiveQZ drawPolygonByPoints:points pointAmount:ARRAY_LENGTH(points) inContext:context withColor:color4];
			
			color = color0;
			[primitiveQZ drawPoint:pointCenter inContext:context withColor:color width:3];
			color = color1;
			[primitiveQZ drawPoint:CGPointMake(160, 240) inContext:context withColor:color1];			
			[primitiveQZ drawRegularPolygon:3 at:pointCenter radius:10 angle:ctrl.angle inContext:context withColor:color];
			[primitiveQZ drawRegularPolygon:4 at:pointCenter radius:20 angle:-ctrl.angle inContext:context 
								withColor:color width:3 solidOrDotted:kLineDotted];
			[primitiveQZ drawRegularPolygon:5 at:pointCenter radius:30 angle:ctrl.angle inContext:context withColor:color];
			[primitiveQZ drawRegularPolygon:6 at:pointCenter radius:40 angle:-ctrl.angle inContext:context 
								withColor:color width:4 solidOrDotted:kLineDotted];
			[primitiveQZ drawRegularPolygon:7 at:pointCenter radius:50 angle:ctrl.angle inContext:context withColor:color];
			[primitiveQZ drawRegularPolygon:8 at:pointCenter radius:60 angle:-ctrl.angle inContext:context 
								withColor:color width:5 cap:kCGLineCapRound join:kCGLineJoinRound solidOrDotted:kLineDotted];
			[primitiveQZ drawRegularPolygon:9 at:pointCenter radius:70 angle:ctrl.angle inContext:context withColor:color];
			[primitiveQZ drawRegularPolygon:10 at:pointCenter radius:80 angle:-ctrl.angle inContext:context 
								withColor:color width:2 solidOrDotted:kLineDotted];
			[primitiveQZ drawRegularPolygon:11 at:pointCenter radius:90 angle:ctrl.angle inContext:context 
								withColor:color width:4 solidOrDotted:kLineSolid];			

			pointStart = CGPointMake(70, 70);
			[primitiveQZ fillRegularPolygon:8 at:pointStart radius:60 angle:22.5 
								inContext:context 
								withColor:color0 fillColor:color5 width:2 cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN 
							solidOrDotted:kLineSolid 
								 pathMode:kCGPathFillStroke];
			
			if (!CGPointEqualToPoint(ctrl.pointTouchBegin, pointCenter)) {
				[primitiveQZ drawPoint:ctrl.pointTouchBegin inContext:context withColor:USER_COLOR width:3];
				[primitiveQZ drawRegularPolygon:(3 + ctrl.lineWidth / 5) at:ctrl.pointTouchBegin 
									   radius:(10 + ctrl.lineWidth * 2) angle:(ctrl.angle * 1) 
									  inContext:context 
									  withColor:USER_COLOR];
			}
			break;
		}
		case kPrimitiveStar: {
			// MARK: star
			color = color0;
			[primitiveQZ drawPoint:pointCenter inContext:context withColor:color width:3];
			color = color1;
			[primitiveQZ drawPoint:pointCenter inContext:context withColor:color1];
			[primitiveQZ drawStar:24 at:pointCenter radius:100 angle:ctrl.angle inContext:context withColor:color];
			[primitiveQZ fillStar:9 at:pointCenter radius:100 angle:ctrl.angle 
					  inContext:context 
					  withColor:color0 fillColor:color width:2 cap:DEFAULT_LINE_CAP join:DEFAULT_LINE_JOIN 
				  solidOrDotted:kLineSolid 
					   pathMode:kCGPathEOFill];
			
			width = 3;
			color = color2;
			pointStart = CGPointMake(60, 60);
			[primitiveQZ drawStar:5 at:pointStart radius:50 angle:(ctrl.angle * 2) inContext:context 
					  withColor:color width:width solidOrDotted:kLineSolid];
			pointStart.x = 260;
			[primitiveQZ drawStar:6 at:pointStart radius:50 angle:(-ctrl.angle * 2) inContext:context 
					  withColor:color width:width solidOrDotted:kLineDotted];
			pointStart.y = 360;
			color = color3;
			[primitiveQZ fillStar:7 at:pointStart radius:50 angle:(ctrl.angle * 2) inContext:context 
					  withColor:color4 fillColor:color width:width cap:kCGLineCapRound join:kCGLineJoinRound 
				  solidOrDotted:kLineSolid pathMode:kCGPathEOFillStroke];
			pointStart.x = 60;
			[primitiveQZ fillStar:8 at:pointStart radius:50 angle:(-ctrl.angle * 2) inContext:context withColor:color];
			
			if (!CGPointEqualToPoint(ctrl.pointTouchBegin, pointCenter)) {
				radius = 10 + ctrl.lineWidth * 2;
				[primitiveQZ drawStar:(3 + ctrl.lineWidth / 5) at:ctrl.pointTouchBegin radius:radius angle:(ctrl.angle * 1) 
						  inContext:context withColor:USER_COLOR];
				if (radius > 20) {
					[primitiveQZ fillStar:(3 + ctrl.lineWidth / 5) at:ctrl.pointTouchBegin 
								   radius:radius - 20 angle:(-ctrl.angle * 2) 
							  inContext:context withColor:USER_COLOR];
				}
			}
			break;
		}
		case kPrimitiveFan: {
			// MARK: fan
			radius = 60;			
			[primitiveQZ fillFanAt:pointCenter radius:radius from:0 to:360 clockwise:kArcClockwise 
					   inContext:context withColor:color];
			color = [UIColor blackColor];
			width = 3;
			[primitiveQZ drawFanAt:pointCenter radius:radius from:0 to:360 clockwise:kArcClockwise 
					   inContext:context withColor:color width:width solidOrDotted:kLineSolid];
			[primitiveQZ fillFanAt:pointCenter radius:radius - 2 from:0 to:360 clockwise:kArcClockwise 
					   inContext:context withColor:color5];
			[primitiveQZ fillFanAt:pointCenter radius:radius - 6 from:60 to:120 clockwise:kArcClockwise 
					   inContext:context withColor:color];
			[primitiveQZ fillFanAt:pointCenter radius:radius - 6 from:180 to:240 clockwise:kArcClockwise 
					   inContext:context withColor:color];
			[primitiveQZ fillFanAt:pointCenter radius:radius - 6 from:300 to:360 clockwise:kArcClockwise 
					   inContext:context withColor:color];
			[primitiveQZ fillFanAt:pointCenter radius:18 from:0 to:360 clockwise:kArcClockwise 
					   inContext:context withColor:color5];
			[primitiveQZ fillFanAt:pointCenter radius:10 from:0 to:360 clockwise:kArcClockwise 
					   inContext:context withColor:color];
			
			float alphaValue = fabs(1 - (ctrl.angle % 20) * 1.0 / 10);
			CLAMP(alphaValue, 0.1, 0.8);
			color = [UIColor colorWithRed:1 green:0 blue:0 alpha:alphaValue];
			[primitiveQZ fillFanAt:pointCenter radius:radius from:270 to:(270 + ctrl.angle) clockwise:kArcCounterClockwise 
					   inContext:context withColor:color];
			
			if (!CGPointEqualToPoint(ctrl.pointTouchBegin, pointCenter)) {
				[primitiveQZ drawPoint:ctrl.pointTouchBegin inContext:context withColor:USER_COLOR width:5];
				[primitiveQZ fillFanAt:ctrl.pointTouchBegin radius:(50 + ctrl.lineWidth) 
								from:(ctrl.angle * 10) to:(ctrl.angle * 10 + 60) clockwise:kArcClockwise 
						   inContext:context withColor:color3];
				[primitiveQZ drawFanAt:ctrl.pointTouchBegin radius:(50 + ctrl.lineWidth) 
								from:(ctrl.angle * 10) to:(ctrl.angle * 10 + 60) clockwise:kArcClockwise 
						   inContext:context 
						   withColor:USER_COLOR width:DEFAULT_LINE_WIDTH cap:kCGLineCapRound join:kCGLineJoinRound 
					   solidOrDotted:kLineDotted];
			}			
			break;
		}
		case kPrimitiveGradient: {
			// MARK: gradient fill
			rect = CGRectMake(50, 20, 100, 100);
			[primitiveQZ fillGradientInRect:rect linearOrRadial:kGradientLinear inContext:context 
							   withColors:color0, color1, color2, color3, nil];
			rect = CGRectMake(80, 150, 100, 100);			
			[primitiveQZ fillGradient:colorsUI colorAmount:ARRAY_LENGTH(colorsUI) inRect:rect 
					   linearOrRadial:kGradientRadial inContext:context];
			rect = CGRectMake(110, 280, 100, 100);
			[primitiveQZ fillGradientInRect:rect linearOrRadial:kGradientRadial 
								inContext:context withComponents:colorsGL amount:(ARRAY_LENGTH(colorsGL) / 4)];
			
			rect = [ctrl rectByTouchDrag];
			[primitiveQZ fillGradientInRect:rect linearOrRadial:(ctrl.angle % 80 < 40) inContext:context 
							   withColors:color1, color3, color4, color5, nil];			
			break;
		}
		case kPrimitiveImage: {
			// MARK: image
			rect = CGRectMake(0, 0, 320, 416);
			NSInteger tempAngle = ctrl.angle;
			[primitiveQZ fillImageNamed:IMAGE_BOARD inRect:self.frame by:kFillByScale inContext:context withTrans:0.2];
			for (int i = 0; i < 4; i++) {
				[primitiveQZ drawImageNamed:IMAGE_SPRITE at:points[i] alignment:kAlignmentHcenterVcenter 
								inContext:context 
								withTrans:0.5 flip:kFlipNone rotate:tempAngle scaleX:0.5 scaleY:0.5];
				[primitiveQZ drawPoint:points[i] inContext:context withColor:color0 width:3];
				tempAngle *= -1;
			}
			
			pointStart = CGPointMake(10, 10);
			[primitiveQZ drawImageNamed:IMAGE_CHECK at:pointStart alignment:kAlignmentLeftTop 
							inContext:context 
							withTrans:0.1 flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
			[primitiveQZ drawPoint:pointStart inContext:context withColor:color0 width:3];
			pointStart = CGPointMake(160, 10);
			[primitiveQZ drawImageNamed:IMAGE_CHECK at:pointStart alignment:kAlignmentHcenterTop 
							inContext:context 
							withTrans:0.2 flip:kFlipX rotate:0 scaleX:1 scaleY:1];
			[primitiveQZ drawPoint:pointStart inContext:context withColor:color0 width:3];
			pointStart = CGPointMake(310, 10);
			[primitiveQZ drawImageNamed:IMAGE_CHECK at:pointStart alignment:kAlignmentRightTop 
							inContext:context 
							withTrans:0.3 flip:kFlipY rotate:0 scaleX:1 scaleY:1];
			[primitiveQZ drawPoint:pointStart inContext:context withColor:color0 width:3];
			pointStart = CGPointMake(10, 208);
			[primitiveQZ drawImageNamed:IMAGE_CHECK at:pointStart alignment:kAlignmentLeftVcenter 
							inContext:context 
							withTrans:0.4 flip:kFlipXY rotate:0 scaleX:1 scaleY:1];
			[primitiveQZ drawPoint:pointStart inContext:context withColor:color0 width:3];
			pointStart = CGPointMake(160, 208);
			[primitiveQZ drawImageNamed:IMAGE_CHECK at:pointStart alignment:kAlignmentHcenterVcenter 
							inContext:context 
							withTrans:0.5 flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
			[primitiveQZ drawPoint:pointStart inContext:context withColor:color0 width:3];
			pointStart = CGPointMake(310, 208);
			[primitiveQZ drawImageNamed:IMAGE_CHECK at:pointStart alignment:kAlignmentRightVcenter 
							inContext:context 
							withTrans:0.6 flip:kFlipX rotate:0 scaleX:1 scaleY:1];
			[primitiveQZ drawPoint:pointStart inContext:context withColor:color0 width:3];
			pointStart = CGPointMake(10, 406);
			[primitiveQZ drawImageNamed:IMAGE_CHECK at:pointStart alignment:kAlignmentLeftBottom 
							inContext:context 
							withTrans:0.7 flip:kFlipY rotate:0 scaleX:1 scaleY:1];
			[primitiveQZ drawPoint:pointStart inContext:context withColor:color0 width:3];
			pointStart = CGPointMake(160, 406);
			[primitiveQZ drawImageNamed:IMAGE_CHECK at:pointStart alignment:kAlignmentHcenterBottom 
							inContext:context 
							withTrans:0.8 flip:kFlipXY rotate:0 scaleX:1 scaleY:1];
			[primitiveQZ drawPoint:pointStart inContext:context withColor:color0 width:3];
			pointStart = CGPointMake(310, 406);
			[primitiveQZ drawImageNamed:IMAGE_CHECK at:pointStart alignment:kAlignmentRightBottom 
							inContext:context 
							withTrans:0.9 flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
			[primitiveQZ drawPoint:pointStart inContext:context withColor:color0 width:3];
			
			rect = [ctrl rectByTouchDrag];
			if (!CGPointEqualToPoint(ctrl.pointTouchBegin, pointCenter) 
				&& (CGPointEqualToPoint(ctrl.pointTouchEnd, pointCenter) || rect.size.width < 50 || rect.size.height < 50)) {
				float scale = (10 - ctrl.lineWidth) / 10;				
				[primitiveQZ drawImageNamed:IMAGE_ICON at:ctrl.pointTouchBegin alignment:kAlignmentHcenterVcenter 
								inContext:context
								withTrans:0.75 flip:kFlipNone rotate:(ctrl.angle * 3) scaleX:scale scaleY:scale];
				[primitiveQZ drawPoint:ctrl.pointTouchBegin inContext:context withColor:USER_COLOR width:3];
			} else {
				[primitiveQZ fillImageNamed:IMAGE_ICON inRect:rect by:kFillByTiled inContext:context withTrans:0.5];
				[primitiveQZ drawRect:rect inContext:context withColor:USER_COLOR];
			}
			break;
		}
		case kPrimitivePDF: {
			// MARK: pdf
			if (CGRectEqualToRect(ctrl.rectContent, CGRectZero)) {
				ctrl.rectContent = self.bounds;
			}
			[primitiveQZ drawPDFNamed:@"Readme.pdf" inRect:ctrl.rectContent inContext:context];			
			break;
		}
		case kPrimitiveText: {
			// MARK: text
			rect = CGRectMake(10, 10, 300, 100);
			switch (ctrl.angle / 45) {
				case 0:
					[primitiveQZ drawText:@"Hello world" inRect:rect inContext:context withColor:color0];
					break;
				case 1:
					rect.origin.y += 30;
					[primitiveQZ drawText:@"Hello world" inRect:rect inContext:context 
							  withColor:color1 font:DEFAULT_FONT size:30];
					break;
				case 2:
					rect.origin.y += 80;
					[primitiveQZ drawText:@"Hello world" inRect:rect inContext:context 
							  withColor:color2 font:DEFAULT_FONT size:40 strokeColor:color3 pathMode:kCGTextFillStrokeClip];
					break;
				case 3:
					rect.origin.y += 150;
					for(int i = 0; i < 32; ++i) {
						glyphs[i] = (ctrl.angle / 45) * 32 + i;
					}
					[primitiveQZ drawGlyphs:glyphs glyphAmount:30 inRect:rect inContext:context withColor:color3];
					break;
				case 4:
					rect.origin.y += 200;
					for(int i = 0; i < 32; ++i) {
						glyphs[i] = (ctrl.angle / 45) * 32 + i;
					}
					[primitiveQZ drawGlyphs:glyphs glyphAmount:20 inRect:rect inContext:context 
								withColor:color4 font:DEFAULT_FONT size:50 strokeColor:USER_COLOR
								 pathMode:kCGTextFillClip];
					break;
				case 5:
					rect.origin.y += 270;
					for(int i = 0; i < 32; ++i) {
						glyphs[i] = (ctrl.angle / 45) * 32 + i;
					}
					[primitiveQZ drawGlyphs:glyphs glyphAmount:10 inRect:rect inContext:context 
								withColor:color5 font:DEFAULT_FONT size:60 strokeColor:USER_COLOR
								 pathMode:kCGTextStrokeClip];
					break;
				default:
					/* FIXME: with bug */
					[primitiveQZ drawText:@"Hello world" inRect:rect inContext:context withColor:color0];
					rect.origin.y += 30;
					[primitiveQZ drawText:@"Hello world" inRect:rect inContext:context 
							  withColor:color1 font:DEFAULT_FONT size:30];
					rect.origin.y += 50;
					[primitiveQZ drawText:@"Hello world" inRect:rect inContext:context 
							  withColor:color2 font:DEFAULT_FONT size:40 strokeColor:color3 pathMode:kCGTextFillStrokeClip];
					rect.origin.y += 70;
					for(int i = 0; i < 32; ++i) {
						glyphs[i] = 3 * 32 + i;
					}
					[primitiveQZ drawGlyphs:glyphs glyphAmount:30 inRect:rect inContext:context withColor:color3];
					rect.origin.y += 50;
					for(int i = 0; i < 32; ++i) {
						glyphs[i] = 4 * 32 + i;
					}
					[primitiveQZ drawGlyphs:glyphs glyphAmount:20 inRect:rect inContext:context 
								withColor:color4 font:DEFAULT_FONT size:50 strokeColor:USER_COLOR
								 pathMode:kCGTextFillClip];
					rect.origin.y += 70;
					for(int i = 0; i < 32; ++i) {
						glyphs[i] = 5 * 32 + i;
					}
					[primitiveQZ drawGlyphs:glyphs glyphAmount:10 inRect:rect inContext:context 
								withColor:color5 font:DEFAULT_FONT size:60 strokeColor:USER_COLOR
								 pathMode:kCGTextStrokeClip];
					break;
			}
			
			if (!CGPointEqualToPoint(ctrl.pointTouchBegin, pointCenter) 
				&& CGPointEqualToPoint(ctrl.pointTouchBegin, ctrl.pointTouchEnd)) {
				ctrl.angle = 45 * (ctrl.angle / 45 + 1);
				ctrl.pointTouchBegin = pointCenter;
			}
			break;
		}
		case kPrimitiveGlyphs:
			// MARK: glyphs
			[self comingsoon:context];
			break;
			
		case kPrimitiveOthers:
			// MARK: others
			[self comingsoon:context];
			break;
	}
}

#pragma mark -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[ctrl touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[ctrl touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[ctrl touchesEnded:touches withEvent:event];
}

#pragma mark -

- (void)comingsoon:(CGContextRef)context {
	[primitiveQZ drawImageNamed:IMAGE_WAIT at:CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2)
					  alignment:kAlignmentHcenterVcenter inContext:context];
}

@end
