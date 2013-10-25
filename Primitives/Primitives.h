//
//  DrawPrimitives.h
//  DrawPrimitivesDemo
//
//  Created by Jiangy on 11-4-26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "MacrosAndType.h"

#pragma mark -

@interface Primitives : NSObject {
	
}

+ (CGFloat)angleBetweenPoint:(CGPoint)startPoint andPoint:(CGPoint)endPoint;
+ (CGPoint)centerOfArcFrom:(CGPoint)startPoint to:(CGPoint)endPoint withRadius:(CGFloat)radius clockwise:(kDrawStyle)clockwise;
+ (UIImage *)glToImage;

@end


#pragma mark -
#pragma mark === Draw Primitives use Quartz ===
#pragma mark -

@interface PrimitivesQZ : Primitives {
	
}

- (void)cleanScreenInContext:(CGContextRef)context;
- (void)cleanScreenInContext:(CGContextRef)context withColor:(UIColor *)color;
- (void)cleanRect:(CGRect)rect inContext:(CGContextRef)context withColor:(UIColor *)color;

#pragma mark -

- (void)drawPoint:(CGPoint)point inContext:(CGContextRef)context withColor:(UIColor *)color;
- (void)drawPoint:(CGPoint)point inContext:(CGContextRef)context withColor:(UIColor *)color width:(CGFloat)width;

#pragma mark -

- (void)drawLineFrom:(CGPoint)startPoint to:(CGPoint)endPoint inContext:(CGContextRef)context withColor:(UIColor *)color;
- (void)drawLineFrom:(CGPoint)startPoint to:(CGPoint)endPoint 
		   inContext:(CGContextRef)context 
		   withColor:(UIColor *)color width:(CGFloat)width 
	   solidOrDotted:(kDrawStyle)isDotted;
- (void)drawLineFrom:(CGPoint)startPoint to:(CGPoint)endPoint 
		   inContext:(CGContextRef)context 
		   withColor:(UIColor *)color width:(CGFloat)width cap:(CGLineCap)cap join:(CGLineJoin)join 
	   solidOrDotted:(kDrawStyle)isDotted;
- (void)drawLines:(CGPoint *)points pointAmount:(NSInteger)count inContext:(CGContextRef)context withColor:(UIColor *)color;
- (void)drawLines:(CGPoint *)points pointAmount:(NSInteger)count 
		inContext:(CGContextRef)context 
		withColor:(UIColor *)color width:(CGFloat)width 
	solidOrDotted:(kDrawStyle)isDotted 
		joinOrSeg:(kDrawStyle)isSeg;
- (void)drawLines:(CGPoint *)points pointAmount:(NSInteger)count 
		inContext:(CGContextRef)context 
		withColor:(UIColor *)color width:(CGFloat)width cap:(CGLineCap)cap join:(CGLineJoin)join 
	solidOrDotted:(kDrawStyle)isDotted 
		joinOrSeg:(kDrawStyle)isSeg;
- (void)drawLinesInContext:(CGContextRef)context withColor:(UIColor *)color 
				   sPoints:(NSString *)s_point, ... NS_REQUIRES_NIL_TERMINATION;
- (void)drawLinesInContext:(CGContextRef)context 
				 withColor:(UIColor *)color width:(CGFloat)width 
			 solidOrDotted:(kDrawStyle)isDotted 
				 joinOrSeg:(kDrawStyle)isSeg  
				   sPoints:(NSString *)s_point, ... NS_REQUIRES_NIL_TERMINATION;
- (void)drawLinesInContext:(CGContextRef)context 
				 withColor:(UIColor *)color width:(CGFloat)width cap:(CGLineCap)cap join:(CGLineJoin)join  
			 solidOrDotted:(kDrawStyle)isDotted 
				 joinOrSeg:(kDrawStyle)isSeg  
				   sPoints:(NSString *)s_point, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark -

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context withColor:(UIColor *)color;
- (void)drawRect:(CGRect)rect 
	   inContext:(CGContextRef)context 
	   withColor:(UIColor *)color width:(CGFloat)width 
   solidOrDotted:(kDrawStyle)isDotted;
- (void)fillRect:(CGRect)rect inContext:(CGContextRef)context withColor:(UIColor *)color;
- (void)drawRects:(CGRect *)rects rectAmount:(NSInteger)count inContext:(CGContextRef)context withColor:(UIColor *)color;
- (void)drawRects:(CGRect *)rects rectAmount:(NSInteger)count  
		inContext:(CGContextRef)context 
		withColor:(UIColor *)color width:(CGFloat)width 
	solidOrDotted:(kDrawStyle)isDotted;
- (void)fillRects:(CGRect *)rects rectAmount:(NSInteger)count inContext:(CGContextRef)context withColor:(UIColor *)color;
- (void)drawRectsInContext:(CGContextRef)context withColor:(UIColor *)color 
					sRects:(NSString *)s_rect, ... NS_REQUIRES_NIL_TERMINATION;
- (void)drawRectsInContext:(CGContextRef)context 
				 withColor:(UIColor *)color width:(CGFloat)width 
			 solidOrDotted:(kDrawStyle)isDotted 
					sRects:(NSString *)s_rect, ... NS_REQUIRES_NIL_TERMINATION;
- (void)fillRectsInContext:(CGContextRef)context 
				 withColor:(UIColor *)color
					sRects:(NSString *)s_rect, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark -

- (void)drawEllipse:(CGRect)rect inContext:(CGContextRef)context withColor:(UIColor *)color;
- (void)drawEllipse:(CGRect)rect 
		  inContext:(CGContextRef)context 
		  withColor:(UIColor *)color width:(CGFloat)width 
	  solidOrDotted:(kDrawStyle)isDotted;
- (void)fillEllipse:(CGRect)rect inContext:(CGContextRef)context withColor:(UIColor *)color;
- (void)drawEllipses:(CGRect *)rects rectAmount:(NSInteger)count inContext:(CGContextRef)context withColor:(UIColor *)color;
- (void)drawEllipses:(CGRect *)rects rectAmount:(NSInteger)count  
		   inContext:(CGContextRef)context 
		   withColor:(UIColor *)color width:(CGFloat)width 
	   solidOrDotted:(kDrawStyle)isDotted;
- (void)fillEllipses:(CGRect *)rects rectAmount:(NSInteger)count inContext:(CGContextRef)context withColor:(UIColor *)color;
- (void)drawEllipsesInContext:(CGContextRef)context withColor:(UIColor *)color 
					   sRects:(NSString *)s_rect, ... NS_REQUIRES_NIL_TERMINATION;
- (void)drawEllipsesInContext:(CGContextRef)context 
					withColor:(UIColor *)color width:(CGFloat)width 
				solidOrDotted:(kDrawStyle)isDotted 
					   sRects:(NSString *)s_rect, ... NS_REQUIRES_NIL_TERMINATION;
- (void)fillEllipsesInContext:(CGContextRef)context 
					withColor:(UIColor *)color
					   sRects:(NSString *)s_rect, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark -

- (void)drawArcAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise 
		inContext:(CGContextRef)context withColor:(UIColor *)color;
- (void)drawArcAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise
		inContext:(CGContextRef)context 
		withColor:(UIColor *)color width:(CGFloat)width 
	solidOrDotted:(kDrawStyle)isDotted;
- (void)drawArcAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise
		inContext:(CGContextRef)context 
		withColor:(UIColor *)color width:(CGFloat)width cap:(CGLineCap)cap join:(CGLineJoin)join 
	solidOrDotted:(kDrawStyle)isDotted;
- (void)fillArcAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise
		inContext:(CGContextRef)context 
		withColor:(UIColor *)color;
- (void)drawArcFrom:(CGPoint)startPoint to:(CGPoint)endPoint radius:(CGFloat)radius clockwise:(kDrawStyle)clockwise 
		  inContext:(CGContextRef)context 
		  withColor:(UIColor *)color;
- (void)drawArcFrom:(CGPoint)startPoint to:(CGPoint)endPoint radius:(CGFloat)radius clockwise:(kDrawStyle)clockwise 
		  inContext:(CGContextRef)context 
		  withColor:(UIColor *)color width:(CGFloat)width 
	  solidOrDotted:(kDrawStyle)isDotted;
- (void)drawArcFrom:(CGPoint)startPoint to:(CGPoint)endPoint radius:(CGFloat)radius clockwise:(kDrawStyle)clockwise 
		  inContext:(CGContextRef)context 
		  withColor:(UIColor *)color width:(CGFloat)width cap:(CGLineCap)cap join:(CGLineJoin)join  
	  solidOrDotted:(kDrawStyle)isDotted;
- (void)fillArcFrom:(CGPoint)startPoint to:(CGPoint)endPoint radius:(CGFloat)radius clockwise:(kDrawStyle)clockwise 
		  inContext:(CGContextRef)context 
		  withColor:(UIColor *)color;

#pragma mark -

- (void)drawBezierCurve:(kBezier)bPoints inContext:(CGContextRef)context withColor:(UIColor *)color;
- (void)drawBezierCurve:(kBezier)bPoints 
			  inContext:(CGContextRef)context 
			  withColor:(UIColor *)color width:(CGFloat)width 
		  solidOrDotted:(kDrawStyle)isDotted;
- (void)drawBezierCurve:(kBezier)bPoints 
			  inContext:(CGContextRef)context 
			  withColor:(UIColor *)color width:(CGFloat)width cap:(CGLineCap)cap join:(CGLineJoin)join 
		  solidOrDotted:(kDrawStyle)isDotted;

#pragma mark -

- (void)addRoundRect:(CGRect)rect radius:(CGFloat)radius toContext:(CGContextRef)context;
- (void)drawRoundRect:(CGRect)rect radius:(CGFloat)radius inContext:(CGContextRef)context withColor:(UIColor *)color;
- (void)drawRoundRect:(CGRect)rect radius:(CGFloat)radius 
			inContext:(CGContextRef)context 
			withColor:(UIColor *)color width:(CGFloat)width  
		solidOrDotted:(kDrawStyle)isDotted;
- (void)fillRoundRect:(CGRect)rect radius:(CGFloat)radius inContext:(CGContextRef)context withColor:(UIColor *)color;

#pragma mark -

- (void)addPolygonByPoints:(CGPoint *)points pointAmount:(NSInteger)count toContext:(CGContextRef)context;
- (void)drawPolygonByPoints:(CGPoint *)points pointAmount:(NSInteger)count 
				  inContext:(CGContextRef)context 
				  withColor:(UIColor *)color;
- (void)drawPolygonByPoints:(CGPoint *)points pointAmount:(NSInteger)count  
				  inContext:(CGContextRef)context 
				  withColor:(UIColor *)color width:(CGFloat)width 
			  solidOrDotted:(kDrawStyle)isDotted;
- (void)drawPolygonByPoints:(CGPoint *)points pointAmount:(NSInteger)count  
				  inContext:(CGContextRef)context 
				  withColor:(UIColor *)color width:(CGFloat)width cap:(CGLineCap)cap join:(CGLineJoin)join 
			  solidOrDotted:(kDrawStyle)isDotted;
- (void)fillPolygonByPoints:(CGPoint *)points pointAmount:(NSInteger)count  
				  inContext:(CGContextRef)context 
				  withColor:(UIColor *)color;
- (void)fillPolygonByPoints:(CGPoint *)points pointAmount:(NSInteger)count  
				  inContext:(CGContextRef)context 
				  withColor:(UIColor *)sColor fillColor:(UIColor *)fColor width:(CGFloat)width
						cap:(CGLineCap)cap join:(CGLineJoin)join
			  solidOrDotted:(kDrawStyle)isDotted 
				   pathMode:(CGPathDrawingMode)mode;

- (void)addReularPolygon:(NSInteger)sideAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
			   toContext:(CGContextRef)context;
- (void)drawRegularPolygon:(NSInteger)sideAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
				 inContext:(CGContextRef)context 
				 withColor:(UIColor *)color;
- (void)drawRegularPolygon:(NSInteger)sideAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
				 inContext:(CGContextRef)context 
				 withColor:(UIColor *)color width:(CGFloat)width 
			 solidOrDotted:(kDrawStyle)isDotted;
- (void)drawRegularPolygon:(NSInteger)sideAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
				 inContext:(CGContextRef)context 
				 withColor:(UIColor *)color width:(CGFloat)width cap:(CGLineCap)cap join:(CGLineJoin)join 
			 solidOrDotted:(kDrawStyle)isDotted;
- (void)fillRegularPolygon:(NSInteger)sideAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
				 inContext:(CGContextRef)context 
				 withColor:(UIColor *)color;
- (void)fillRegularPolygon:(NSInteger)sideAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
				 inContext:(CGContextRef)context 
				 withColor:(UIColor *)sColor fillColor:(UIColor *)fColor width:(CGFloat)width
					   cap:(CGLineCap)cap join:(CGLineJoin)join
			 solidOrDotted:(kDrawStyle)isDotted 
				  pathMode:(CGPathDrawingMode)mode;

#pragma mark -

- (void)addStar:(NSInteger)pointAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
	  toContext:(CGContextRef)context;
- (void)drawStar:(NSInteger)pointAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
	   inContext:(CGContextRef)context 
	   withColor:(UIColor *)color;
- (void)drawStar:(NSInteger)pointAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
	   inContext:(CGContextRef)context 
	   withColor:(UIColor *)color width:(CGFloat)width 
   solidOrDotted:(kDrawStyle)isDotted;
- (void)drawStar:(NSInteger)pointAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
	   inContext:(CGContextRef)context 
	   withColor:(UIColor *)color width:(CGFloat)width cap:(CGLineCap)cap join:(CGLineJoin)join 
   solidOrDotted:(kDrawStyle)isDotted;
- (void)fillStar:(NSInteger)pointAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
	   inContext:(CGContextRef)context 
	   withColor:(UIColor *)color;
- (void)fillStar:(NSInteger)pointAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
	   inContext:(CGContextRef)context 
	   withColor:(UIColor *)sColor fillColor:(UIColor *)fColor width:(CGFloat)width
			 cap:(CGLineCap)cap join:(CGLineJoin)join
   solidOrDotted:(kDrawStyle)isDotted 
		pathMode:(CGPathDrawingMode)mode;

#pragma mark -

- (void)addFanAt:(CGPoint)center radius:(CGFloat)radius 
			from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise
	   toContext:(CGContextRef)context;
- (void)drawFanAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise 
		inContext:(CGContextRef)context withColor:(UIColor *)color;
- (void)drawFanAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise
		inContext:(CGContextRef)context 
		withColor:(UIColor *)color width:(CGFloat)width 
	solidOrDotted:(kDrawStyle)isDotted;
- (void)drawFanAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise
		inContext:(CGContextRef)context 
		withColor:(UIColor *)color width:(CGFloat)width cap:(CGLineCap)cap join:(CGLineJoin)join 
	solidOrDotted:(kDrawStyle)isDotted;
- (void)fillFanAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise
		inContext:(CGContextRef)context 
		withColor:(UIColor *)color;

#pragma mark -

- (void)fillGradient:(UIColor **)colors colorAmount:(NSInteger)count inRect:(CGRect)rect linearOrRadial:(kDrawStyle)isLinear 
		   inContext:(CGContextRef)context;
- (void)fillGradientInRect:(CGRect)rect linearOrRadial:(kDrawStyle)isLinear 
				 inContext:(CGContextRef)context
				withColors:(UIColor *)color, ... NS_REQUIRES_NIL_TERMINATION;
- (void)fillGradientInRect:(CGRect)rect linearOrRadial:(kDrawStyle)isLinear 
				 inContext:(CGContextRef)context 
			withComponents:(CGFloat *)components amount:(NSInteger)count;

#pragma mark -

- (void)drawImage:(UIImage *)image at:(CGPoint)position inContext:(CGContextRef)context;
- (void)drawImage:(UIImage *)image at:(CGPoint)position inContext:(CGContextRef)context withTrans:(CGFloat)alpha;
- (void)drawImage:(UIImage *)image at:(CGPoint)position alignment:(kDrawStyle)alignment inContext:(CGContextRef)context;
- (void)drawImage:(UIImage *)image at:(CGPoint)position alignment:(kDrawStyle)alignment 
		inContext:(CGContextRef)context 
		withTrans:(CGFloat)alpha;
- (void)drawImage:(UIImage *)image at:(CGPoint)position alignment:(kDrawStyle)alignment
		inContext:(CGContextRef)context 
		withTrans:(CGFloat)alpha flip:(kDrawStyle)flip rotate:(CGFloat)angle scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY;
- (void)drawImageNamed:(NSString *)name at:(CGPoint)position inContext:(CGContextRef)context;
- (void)drawImageNamed:(NSString *)name at:(CGPoint)position 
			 inContext:(CGContextRef)context 
			 withTrans:(CGFloat)alpha;
- (void)drawImageNamed:(NSString *)name at:(CGPoint)position alignment:(kDrawStyle)alignment inContext:(CGContextRef)context;
- (void)drawImageNamed:(NSString *)name at:(CGPoint)position alignment:(kDrawStyle)alignment
			 inContext:(CGContextRef)context 
			 withTrans:(CGFloat)alpha;
- (void)drawImageNamed:(NSString *)name at:(CGPoint)position alignment:(kDrawStyle)alignment
			 inContext:(CGContextRef)context
			 withTrans:(CGFloat)alpha flip:(kDrawStyle)flip rotate:(CGFloat)angle scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY;

- (void)fillImage:(UIImage *)image inRect:(CGRect)rect by:(kDrawStyle)fillType inContext:(CGContextRef)context;
- (void)fillImage:(UIImage *)image inRect:(CGRect)rect by:(kDrawStyle)fillType 
		inContext:(CGContextRef)context 
		withTrans:(CGFloat)alpha;
- (void)fillImage:(UIImage *)image inRect:(CGRect)rect by:(kDrawStyle)fillType 
		inContext:(CGContextRef)context
		withTrans:(CGFloat)alpha flip:(kDrawStyle)flip rotate:(CGFloat)angle scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY;
- (void)fillImageNamed:(NSString *)name inRect:(CGRect)rect by:(kDrawStyle)fillType inContext:(CGContextRef)context;
- (void)fillImageNamed:(NSString *)name inRect:(CGRect)rect by:(kDrawStyle)fillType 
			 inContext:(CGContextRef)context 
			 withTrans:(CGFloat)alpha;
- (void)fillImageNamed:(NSString *)name inRect:(CGRect)rect by:(kDrawStyle)fillType 
			 inContext:(CGContextRef)context
			 withTrans:(CGFloat)alpha flip:(kDrawStyle)flip rotate:(CGFloat)angle scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY;

#pragma mark -

- (void)drawPDFNamed:(NSString *)name inContext:(CGContextRef)context;
- (void)drawPDFNamed:(NSString *)name at:(CGPoint)position inContext:(CGContextRef)context;
- (void)drawPDFNamed:(NSString *)name inRect:(CGRect)rect inContext:(CGContextRef)context;

#pragma mark -

- (void)drawText:(NSString *)content inRect:(CGRect)rect inContext:(CGContextRef)context;
- (void)drawText:(NSString *)content inRect:(CGRect)rect inContext:(CGContextRef)context withColor:(UIColor *)color;
- (void)drawText:(NSString *)content inRect:(CGRect)rect 
	   inContext:(CGContextRef)context 
	   withColor:(UIColor *)color font:(NSString *)font size:(NSInteger)size;
- (void)drawText:(NSString *)content inRect:(CGRect)rect
	   inContext:(CGContextRef)context 
	   withColor:(UIColor *)color font:(NSString *)font size:(NSInteger)size 
	 strokeColor:(UIColor *)sColor pathMode:(CGTextDrawingMode)mode;

- (void)drawGlyphs:(CGGlyph *)glyphs glyphAmount:(NSInteger)count inRect:(CGRect)rect inContext:(CGContextRef)context;
- (void)drawGlyphs:(CGGlyph *)glyphs glyphAmount:(NSInteger)count inRect:(CGRect)rect 
		 inContext:(CGContextRef)context 
		 withColor:(UIColor *)color;
- (void)drawGlyphs:(CGGlyph *)glyphs glyphAmount:(NSInteger)count inRect:(CGRect)rect 
		 inContext:(CGContextRef)context 
		 withColor:(UIColor *)color font:(NSString *)font size:(NSInteger)size;
- (void)drawGlyphs:(CGGlyph *)glyphs glyphAmount:(NSInteger)count inRect:(CGRect)rect 
		 inContext:(CGContextRef)context 
		 withColor:(UIColor *)color font:(NSString *)font size:(NSInteger)size 
	   strokeColor:(UIColor *)sColor pathMode:(CGTextDrawingMode)mode;

@end


#pragma mark -
#pragma mark === Draw Primitives use OpenGL ===
#pragma mark -

@interface PrimitivesGL : Primitives {
	BOOL				checkError;
	CGSize				deviceSize;
	
	GLuint				textures[MAX_TEXTURE];
	CGSize				textureSize[MAX_TEXTURE];
	NSInteger			currTexture, nextTexture;
	
	NSMutableArray *	texturesArray;
}

@property BOOL			checkError;

- (id)initWithDeviceSize:(CGSize)size;

#pragma mark -

- (void)cleanScreenInContext:(EAGLContext *)context;
- (void)cleanScreenInContext:(EAGLContext *)context withColor:(UIColor *)color;
- (void)cleanRect:(CGRect)rect inContext:(EAGLContext *)context withColor:(UIColor *)color;

- (void)checkGLError:(BOOL)visibleCheck;
- (CGSize)loadTextureWithImage:(UIImage *)uiImage orName:(NSString *)imageName;

#pragma mark -

- (void)drawPoint:(CGPoint)point inContext:(EAGLContext *)context withColor:(UIColor *)color;
- (void)drawPoint:(CGPoint)point inContext:(EAGLContext *)context withColor:(UIColor *)color width:(CGFloat)width;
- (void)drawPoints:(CGPoint *)points pointAmount:(NSInteger)count inContext:(EAGLContext *)context withColor:(UIColor *)color;
- (void)drawPoints:(CGPoint *)points pointAmount:(NSInteger)count 
		 inContext:(EAGLContext *)context 
		 withColor:(UIColor *)color width:(CGFloat)width;
- (void)drawPointsInContext:(EAGLContext *)context withColor:(UIColor *)color width:(CGFloat)width
					 points:(NSString *)s_point, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark -

- (void)drawLineFrom:(CGPoint)startPoint to:(CGPoint)endPoint inContext:(EAGLContext *)context withColor:(UIColor *)color;
- (void)drawLineFrom:(CGPoint)startPoint to:(CGPoint)endPoint 
		   inContext:(EAGLContext *)context 
		   withColor:(UIColor *)color width:(CGFloat)width;
- (void)drawLines:(CGPoint *)points pointAmount:(NSInteger)count inContext:(EAGLContext *)context withColor:(UIColor *)color;
- (void)drawLines:(CGPoint *)points pointAmount:(NSInteger)count 
		inContext:(EAGLContext *)context 
		withColor:(UIColor *)color width:(CGFloat)width;
- (void)drawLines:(CGPoint *)points pointAmount:(NSInteger)count 
		inContext:(EAGLContext *)context 
		withColor:(UIColor *)color width:(CGFloat)width 
		joinOrSeg:(kDrawStyle)isSeg;
- (void)drawLinesInContext:(EAGLContext *)context 
				 withColor:(UIColor *)color width:(CGFloat)width 
				 joinOrSeg:(kDrawStyle)isSeg
				   sPoints:(NSString *)s_point, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark -

- (void)drawRect:(CGRect)rect inContext:(EAGLContext *)context withColor:(UIColor *)color;
- (void)drawRect:(CGRect)rect 
	   inContext:(EAGLContext *)context 
	   withColor:(UIColor *)color width:(CGFloat)width;
- (void)fillRect:(CGRect)rect inContext:(EAGLContext *)context withColor:(UIColor *)color gradient:(const GLfloat *)glColors;
- (void)drawRects:(CGRect *)rects rectAmount:(NSInteger)count inContext:(EAGLContext *)context withColor:(UIColor *)color;
- (void)drawRects:(CGRect *)rects rectAmount:(NSInteger)count  
		inContext:(EAGLContext *)context 
		withColor:(UIColor *)color width:(CGFloat)width;
- (void)fillRects:(CGRect *)rects rectAmount:(NSInteger)count 
		inContext:(EAGLContext *)context 
		withColor:(UIColor *)color gradient:(const GLfloat *)glColors;
- (void)drawRectsInContext:(EAGLContext *)context 
				 withColor:(UIColor *)color width:(CGFloat)width 
					sRects:(NSString *)s_rect, ... NS_REQUIRES_NIL_TERMINATION;
- (void)fillRectsInContext:(EAGLContext *)context 
				 withColor:(UIColor *)color gradient:(const GLfloat *)glColors
					sRects:(NSString *)s_rect, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark -

- (void)drawEllipse:(CGRect)rect inContext:(EAGLContext *)context withColor:(UIColor *)color;
- (void)drawEllipse:(CGRect)rect 
		  inContext:(EAGLContext *)context 
		  withColor:(UIColor *)color width:(CGFloat)width;
- (void)fillEllipse:(CGRect)rect inContext:(EAGLContext *)context withColor:(UIColor *)color gradient:(const GLfloat *)glColors;
- (void)drawEllipses:(CGRect *)rects rectAmount:(NSInteger)count inContext:(EAGLContext *)context withColor:(UIColor *)color;
- (void)drawEllipses:(CGRect *)rects rectAmount:(NSInteger)count  
		   inContext:(EAGLContext *)context 
		   withColor:(UIColor *)color width:(CGFloat)width;
- (void)fillEllipses:(CGRect *)rects rectAmount:(NSInteger)count 
		   inContext:(EAGLContext *)context 
		   withColor:(UIColor *)color gradient:(const GLfloat *)glColors;
- (void)drawEllipsesInContext:(EAGLContext *)context 
					withColor:(UIColor *)color width:(CGFloat)width 
					   sRects:(NSString *)s_rect, ... NS_REQUIRES_NIL_TERMINATION;
- (void)fillEllipsesInContext:(EAGLContext *)context 
					withColor:(UIColor *)color gradient:(const GLfloat *)glColors
					   sRects:(NSString *)s_rect, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark -

- (void)drawArcAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise 
		inContext:(EAGLContext *)context withColor:(UIColor *)color;
- (void)drawArcAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise
		inContext:(EAGLContext *)context 
		withColor:(UIColor *)color width:(CGFloat)width;
- (void)fillArcAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise
		inContext:(EAGLContext *)context 
		withColor:(UIColor *)color gradient:(const GLfloat *)glColors;
- (void)drawArcFrom:(CGPoint)startPoint to:(CGPoint)endPoint radius:(CGFloat)radius clockwise:(kDrawStyle)clockwise 
		  inContext:(EAGLContext *)context 
		  withColor:(UIColor *)color;
- (void)drawArcFrom:(CGPoint)startPoint to:(CGPoint)endPoint radius:(CGFloat)radius clockwise:(kDrawStyle)clockwise 
		  inContext:(EAGLContext *)context 
		  withColor:(UIColor *)color width:(CGFloat)width;
- (void)fillArcFrom:(CGPoint)startPoint to:(CGPoint)endPoint radius:(CGFloat)radius clockwise:(kDrawStyle)clockwise 
		  inContext:(EAGLContext *)context 
		  withColor:(UIColor *)color gradient:(const GLfloat *)glColors;

#pragma mark -

- (void)drawBezierCurve:(kBezier)bPoints inContext:(EAGLContext *)context withColor:(UIColor *)color;
- (void)drawBezierCurve:(kBezier)bPoints 
			  inContext:(EAGLContext *)context 
			  withColor:(UIColor *)color width:(CGFloat)width;

#pragma mark -

- (void)drawRoundRect:(CGRect)rect radius:(CGFloat)radius inContext:(EAGLContext *)context withColor:(UIColor *)color;
- (void)drawRoundRect:(CGRect)rect radius:(CGFloat)radius 
			inContext:(EAGLContext *)context 
			withColor:(UIColor *)color width:(CGFloat)width;
- (void)fillRoundRect:(CGRect)rect radius:(CGFloat)radius 
			inContext:(EAGLContext *)context 
			withColor:(UIColor *)color gradient:(const GLfloat *)glColors;

#pragma mark -

- (void)drawPolygonByPoints:(CGPoint *)points pointAmount:(NSInteger)count 
				  inContext:(EAGLContext *)context 
				  withColor:(UIColor *)color;
- (void)drawPolygonByPoints:(CGPoint *)points pointAmount:(NSInteger)count  
				  inContext:(EAGLContext *)context 
				  withColor:(UIColor *)color width:(CGFloat)width;
- (void)fillPolygonByPoints:(CGPoint *)points pointAmount:(NSInteger)count  
				  inContext:(EAGLContext *)context 
				  withColor:(UIColor *)color gradient:(const GLfloat *)glColors;

- (void)drawRegularPolygon:(NSInteger)sideAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
				 inContext:(EAGLContext *)context 
				 withColor:(UIColor *)color;
- (void)drawRegularPolygon:(NSInteger)sideAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
				 inContext:(EAGLContext *)context 
				 withColor:(UIColor *)color width:(CGFloat)width;
- (void)fillRegularPolygon:(NSInteger)sideAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
				 inContext:(EAGLContext *)context 
				 withColor:(UIColor *)color gradient:(const GLfloat *)glColors;

#pragma mark -

- (void)drawStar:(NSInteger)pointAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
	   inContext:(EAGLContext *)context 
	   withColor:(UIColor *)color;
- (void)drawStar:(NSInteger)pointAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
	   inContext:(EAGLContext *)context 
	   withColor:(UIColor *)color width:(CGFloat)width;
- (void)fillStar:(NSInteger)pointAmount at:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle 
	   inContext:(EAGLContext *)context 
	   withColor:(UIColor *)color gradient:(const GLfloat *)glColors;

#pragma mark -

- (void)drawFanAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise 
		inContext:(EAGLContext *)context withColor:(UIColor *)color;
- (void)drawFanAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise
		inContext:(EAGLContext *)context 
		withColor:(UIColor *)color width:(CGFloat)width;
- (void)fillFanAt:(CGPoint)center radius:(CGFloat)radius 
			 from:(CGFloat)startAngle to:(CGFloat)endAngle clockwise:(kDrawStyle)clockwise
		inContext:(EAGLContext *)context 
		withColor:(UIColor *)color gradient:(const GLfloat *)glColors;

#pragma mark -

- (void)drawImage:(UIImage *)image at:(CGPoint)position inContext:(EAGLContext *)context;
- (void)drawImage:(UIImage *)image at:(CGPoint)position inContext:(EAGLContext *)context withTrans:(CGFloat)alpha;
- (void)drawImage:(UIImage *)image at:(CGPoint)position alignment:(kDrawStyle)alignment
		inContext:(EAGLContext *)context;
- (void)drawImage:(UIImage *)image at:(CGPoint)position alignment:(kDrawStyle)alignment
		inContext:(EAGLContext *)context  withTrans:(CGFloat)alpha;
- (void)drawImage:(UIImage *)image at:(CGPoint)position alignment:(kDrawStyle)alignment 
		inContext:(EAGLContext *)context 
		withTrans:(CGFloat)alpha flip:(kDrawStyle)flip rotate:(CGFloat)angle scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY;
- (void)drawImageNamed:(NSString *)name at:(CGPoint)position inContext:(EAGLContext *)context;
- (void)drawImageNamed:(NSString *)name at:(CGPoint)position 
			 inContext:(EAGLContext *)context 
			 withTrans:(CGFloat)alpha;
- (void)drawImageNamed:(NSString *)name at:(CGPoint)position alignment:(kDrawStyle)alignment
			 inContext:(EAGLContext *)context;
- (void)drawImageNamed:(NSString *)name at:(CGPoint)position alignment:(kDrawStyle)alignment 
			 inContext:(EAGLContext *)context 
			 withTrans:(CGFloat)alpha;
- (void)drawImageNamed:(NSString *)name at:(CGPoint)position alignment:(kDrawStyle)alignment 
			 inContext:(EAGLContext *)context
			 withTrans:(CGFloat)alpha flip:(kDrawStyle)flip rotate:(CGFloat)angle scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY;

- (void)fillImage:(UIImage *)image inRect:(CGRect)rect inContext:(EAGLContext *)context;
- (void)fillImage:(UIImage *)image inRect:(CGRect)rect inContext:(EAGLContext *)context withTrans:(CGFloat)alpha;
- (void)fillImage:(UIImage *)image inRect:(CGRect)rect 
		inContext:(EAGLContext *)context 
		withTrans:(CGFloat)alpha flip:(kDrawStyle)flip rotate:(CGFloat)angle;
- (void)fillImageNamed:(NSString *)name inRect:(CGRect)rect inContext:(EAGLContext *)context;
- (void)fillImageNamed:(NSString *)name inRect:(CGRect)rect
			 inContext:(EAGLContext *)context 
			 withTrans:(CGFloat)alpha;
- (void)fillImageNamed:(NSString *)name inRect:(CGRect)rect
			 inContext:(EAGLContext *)context
			 withTrans:(CGFloat)alpha flip:(kDrawStyle)flip rotate:(CGFloat)angle;

- (void)drawTexture:(GLuint)texture inRect:(CGRect)rect 
		  inContext:(EAGLContext *)context 
		  withTrans:(CGFloat)alpha flip:(kDrawStyle)flip rotate:(CGFloat)angle;
- (void)drawTexture:(GLuint)texture at:(CGPoint)center 
	   inContextext:(EAGLContext *)context 
			   from:(CGFloat)startAngle to:(CGFloat)endAngle;

@end
