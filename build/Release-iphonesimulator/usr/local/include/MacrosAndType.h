//
//  Macros.h
//  DrawPrimitivesDemo
//
//  Created by Jiangy on 11-4-26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum DRAW_STYLE {
	kAlignmentLeftTop,
	kAlignmentLeftVcenter,
	kAlignmentLeftBottom,
	kAlignmentHcenterTop,
	kAlignmentHcenterVcenter,
	kAlignmentHcenterBottom,
	kAlignmentRightTop,
	kAlignmentRightVcenter,
	kAlignmentRightBottom,
	
	kLineSolid = NO,
	kLineDotted = YES,
	kLineSegments = YES,
	kLineJoin = NO,
	
	kArcClockwise = 0,
	kArcCounterClockwise = 1,
	
	kFlipNone = UIImageOrientationUp,
	kFlipX = UIImageOrientationUpMirrored,
	kFlipY = UIImageOrientationRightMirrored,
	kFlipXY = UIImageOrientationDown,
	
	kFillByScale = 0,
	kFillByTiled = 1,
	
	kGradientLinear = YES,
	kGradientRadial = NO,
	
}kDrawStyle;

typedef struct BezierPoints {
	CGPoint sp;			// start point
	CGPoint ep;			// end point
	CGPoint cp1;		// controll point 1
	CGPoint cp2;		// controll point 2
}kBezier;


#define DEFAULT_LINE_WIDTH				1
#define DEFAULT_LINE_CAP				kCGLineCapButt
#define DEFAULT_LINE_JOIN				kCGLineJoinMiter
#define DEFAULT_ALIGNMENT				kAlignmentLeftTop
#define DEFAULT_FONT					@"Helvetica"
#define DEFAULT_FONT_SIZE				20
#define DEFAULT_COLOR					[UIColor colorWithRed:1 green:1 blue:1 alpha:1]

#define ARRAY_LENGTH(_array)			sizeof(_array) / sizeof(_array[0])

#define textLength(_text)				strlen(_text)

#define sPoint(_point)					NSStringFromCGPoint(_point)
#define pString(_string)				CGPointFromString(_string)
#define sRect(_rect)					NSStringFromCGRect(_rect)
#define rString(_string)				CGRectFromString(_string)

#define SWAP(_a, _b)					__typeof__(_a) temp; temp = _a; _a = _b; _b = temp
#define CLAMP(_value, _lower, _upper)			_value = MIN(MAX(_lower, _value), _upper)
#define VALUE_BETWEEN(_value, _lower, _upper)	(_value > _lower && _value < _upper)


#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) / M_PI * 180.0)

#define DISTANCE_BETWEEN_POINT(_startPoint, _endPoint)								\
			sqrtf(powf(_startPoint.x - _endPoint.x, 2) + powf(_startPoint.y - _endPoint.y, 2))

#define LOG_INFO(_info, _method)													\
			NSString * METHOD_INFO = @" %@ ";										\
			NSLog([_info stringByAppendingString:METHOD_INFO], _method)

//MARK: for Quartz 2D ("CONTEXT" as mark)

#define DEFAULT_CONTEXT					UIGraphicsGetCurrentContext()

#define CONTEXT_DRAW(_context)			CGContextStrokePath(_context)

#define CONTEXT_FILL(_context)			CGContextFillPath(_context)

#define CONTEXT_EOFILL					CGContestEOFillPath(_context)

#define DEFAULT_CONTEXT_WITH_COLOR_WIDTH(_color, _width)							\
			CGContextRef context = UIGraphicsGetCurrentContext();					\
			CGContextSetStrokeColorWithColor(context, _color.CGColor);				\
			CGContextSetFillColorWithColor(context, _color.CGColor);				\
			CGContextSetLineWidth(context, _width)

#define SET_CONTEXT_WITH_COLOR(_context, _color)									\
			SET_CONTEXT_WITH_COLOR_WIDTH(_context, _color, DEFAULT_LINE_WIDTH)

#define SET_CONTEXT_WITH_COLOR_WIDTH(_context, _color, _width)						\
			CGContextSetStrokeColorWithColor(_context, _color.CGColor);				\
			CGContextSetFillColorWithColor(_context, _color.CGColor);				\
			CGContextSetLineWidth(_context, _width)

#define SET_CONTEXT_WITH_CAP_JOIN(_context, _cap, _join)							\
			CGContextSetLineCap(_context, _cap);									\
			CGContextSetLineJoin(_context, _join)

#define SET_CONTEXT_WITH_ARGS(_context, _sSolor, _fColor, _width, _cap, _join)		\
			CGContextSetStrokeColorWithColor(_context, _sSolor.CGColor);			\
			CGContextSetFillColorWithColor(_context, _fColor.CGColor);				\
			CGContextSetLineWidth(_context, _width);								\
			CGContextSetLineCap(_context, _cap);									\
			CGContextSetLineJoin(_context, _join)

#define SET_CONTEXT_LINE_STYPE(_context, _dotted)									\
			if (_dotted) {															\
				DOTTED_LINE_IN_CONTEXT(_context);									\
			} else {																\
				SOLID_LINE_IN_CONTEXT(_context);									\
			}

#define SOLID_LINE_IN_CONTEXT(_context)												\
			CGContextSetLineDash(_context, 0, nil, 0)

#define DOTTED_LINE_IN_CONTEXT(_context)											\
			CGFloat dash[] = {10, 10};												\
			CGContextSetLineDash(_context, 0, dash, 2)

#define CONTEXT_DRAW_WITH_ARGS(_context, _color, _width, _cap, _join, _dotted)		\
			CGContextSaveGState(_context);											\
			SET_CONTEXT_WITH_COLOR_WIDTH(_context, _color, _width);					\
			SET_CONTEXT_WITH_CAP_JOIN(_context, _cap, _join);						\
			SET_CONTEXT_LINE_STYPE(_context, _dotted)								\
			CONTEXT_DRAW(_context);													\
			CGContextRestoreGState(_context)

//MARK: for OpenGL ES ("GL" as mark)

#define DEFAULT_DEPTH		0
#define MAX_TEXTURE			20

#define CG_X_TO_GL(_x, _deviceSize)		(_x - _deviceSize.width / 2) / (MIN(_deviceSize.width, _deviceSize.height) / 2)
#define CG_Y_TO_GL(_y, _deviceSize)		(_y - _deviceSize.height / 2) / (MIN(_deviceSize.width, _deviceSize.height) / 2)
#define TEX_X_TO_VER(_x, _deviceSize)	(_x - 0.5) * 2 * (_deviceSize.width / MIN(_deviceSize.width, _deviceSize.height))
#define TEX_Y_TO_VER(_y, _deviceSize)	(_y - 0.5) * 2 * (_deviceSize.height / MIN(_deviceSize.width, _deviceSize.height))
#define VER_X_TO_TEX(_x, _deviceSize)	(_x / (_deviceSize.width / MIN(_deviceSize.width, _deviceSize.height)) / 2 + 0.5)
#define VER_Y_TO_TEX(_y, _deviceSize)	(_y / (_deviceSize.height / MIN(_deviceSize.width, _deviceSize.height)) / 2 + 0.5)

#define GL_EXCEPTION(_context)														\
			if (!_context) {														\
				LOG_INFO(@"EAGLContext is nil", self);								\
				return;																\
			}

#define SET_GL_WITH_COLOR(_color)													\
			const CGFloat * components = CGColorGetComponents(_color.CGColor);		\
			CGFloat alpha = CGColorGetAlpha(_color.CGColor);						\
			glColor4f(components[0], components[1], components[2], alpha)

#define SET_GL_WITH_COLOR_WIDTH(_color, _width)										\
			SET_GL_WITH_COLOR(_color);												\
			glLineWidth(DEFAULT_LINE_WIDTH)

#define GL_DRAW_ARRAY(_context, _color, _glColors, _width, _vertices, _first, _count, _mode)				\
			GL_EXCEPTION(_context);													\
			glPushMatrix();															\
			{																		\
				glScalef(1, -1, 1);													\
				if (_color) {														\
					SET_GL_WITH_COLOR(_color);										\
				} else {															\
					glColorPointer(4, GL_FLOAT, 0, _glColors);						\
					glEnableClientState(GL_COLOR_ARRAY);							\
				}																	\
				glVertexPointer(3, GL_FLOAT, 0, _vertices);							\
				glEnableClientState(GL_VERTEX_ARRAY);								\
				glPointSize(_width);												\
				glLineWidth(_width);												\
				glDrawArrays(_mode, _first, _count);								\
				glDisableClientState(GL_COLOR_ARRAY);								\
			}																		\
			glPopMatrix()


