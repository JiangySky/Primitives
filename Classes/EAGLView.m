#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "EAGLView.h"
#import "PrimitiveController.h"

#define USE_DEPTH_BUFFER 1

#define kInnerCircleRadius	1.0
#define kOuterCircleRadius	1.1
#define kCubeScale			0.12
#define kButtonScale		0.1
#define kButtonLeftSpace	1.1

@interface EAGLView (EAGLViewPrivate)

- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;

@end

@interface EAGLView (EAGLViewSprite)

- (void)setupView;
- (void)loadTexture:(NSString *)name;
- (void)update;

@end

@implementation EAGLView

@synthesize animating;
@dynamic animationFrameInterval;
@synthesize primitiveGL;


// You must implement this
+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder *)coder
{
	if((self = [super initWithCoder:coder])) {
		// Get the layer
		CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
		
		eaglLayer.opaque = YES;
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		
		if(!context || ![EAGLContext setCurrentContext:context] || ![self createFramebuffer]) {
			[self release];
			return nil;
		}
		
		animating = FALSE;
		displayLinkSupported = FALSE;
		animationFrameInterval = 1;
		displayLink = nil;
		animationTimer = nil;
		
		// A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
		// class is used as fallback when it isn't available.
		NSString *reqSysVer = @"3.1";
		NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
		if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
			displayLinkSupported = TRUE;
		
		[self setupView];
		[self drawView];
	}
	
	return self;
}


- (void)layoutSubviews
{
	[EAGLContext setCurrentContext:context];
	[self destroyFramebuffer];
	[self createFramebuffer];
	[self drawView];
	
}


- (BOOL)createFramebuffer
{
	glGenFramebuffersOES(1, &viewFramebuffer);
	glGenRenderbuffersOES(1, &viewRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
		
	if (USE_DEPTH_BUFFER) {
		glGenRenderbuffersOES(1, &depthRenderbuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
		glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
	}
	
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
	
	return YES;
}


- (void)destroyFramebuffer
{
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;
	
	if(depthRenderbuffer) {
		glDeleteRenderbuffersOES(1, &depthRenderbuffer);
		depthRenderbuffer = 0;
	}
}


- (NSInteger) animationFrameInterval
{
	return animationFrameInterval;
}

- (void) setAnimationFrameInterval:(NSInteger)frameInterval
{
	// Frame interval defines how many display frames must pass between each time the
	// display link fires. The display link will only fire 30 times a second when the
	// frame internal is two on a display that refreshes 60 times a second. The default
	// frame interval setting of one will fire 60 times a second when the display refreshes
	// at 60 times a second. A frame interval setting of less than one results in undefined
	// behavior.
	if (frameInterval >= 1)
	{
		animationFrameInterval = frameInterval;
		
		if (animating)
		{
			[self stopAnimation];
			[self startAnimation];
		}
	}
}

- (void) startAnimation
{
	if (!animating)
	{
		if (displayLinkSupported)
		{
			// CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
			// if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
			// not be called in system versions earlier than 3.1.
			
			displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView)];
			[displayLink setFrameInterval:animationFrameInterval];
			[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		}
		else
			animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) 
															  target:self selector:@selector(drawView) userInfo:nil repeats:TRUE];
		
		animating = TRUE;
	}
}

- (void)stopAnimation
{
	if (animating)
	{
		if (displayLinkSupported)
		{
			[displayLink invalidate];
			displayLink = nil;
		}
		else
		{
			[animationTimer invalidate];
			animationTimer = nil;
		}
		
		animating = FALSE;
	}
}

- (void)initWithController:(PrimitiveController *)controller {
	ctrl = controller;
	
	if (!primitiveGL) {
		primitiveGL = [[PrimitivesGL alloc] initWithDeviceSize:self.bounds.size];
	}
	
	UILongPressGestureRecognizer * press = [[UILongPressGestureRecognizer alloc] initWithTarget:ctrl action:@selector(longPress:)];
	[press setMinimumPressDuration:1.0f];
	[self addGestureRecognizer:press];
	[press release];
	
	UIPinchGestureRecognizer * pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:ctrl action:@selector(pinch:)];
	[self addGestureRecognizer:pinch];
	[pinch release];
}

- (void)setupView
{	
	// Sets up matrices and transforms for OpenGL ES
	glViewport(0, 0, backingWidth, backingHeight);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(-1.0f, 1.0f, -1.5f, 1.5f, -1.0f, 1.0f);
	glMatrixMode(GL_MODELVIEW);
	
	// Clears the view with black
	glClearColor(1, 1, 1, 1);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
}


- (void)loadTexture:(NSString *)name
{
	CGImageRef image = [UIImage imageNamed:name].CGImage;
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
}

- (void)drawRect:(CGRect)rect {
	
}

// Updates the OpenGL view when the timer fires
- (void)drawView
{
	// Make sure that you are drawing to the current context
	[EAGLContext setCurrentContext:context];
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
#pragma mark -
	[primitiveGL cleanScreenInContext:context];
	
	// MARK: set some args here
	float width = DEFAULT_LINE_WIDTH;
	float radius = 30;
	const CGPoint pointCenter = CGPointMake(self.frame.size.width / 2, (self.frame.size.height - 64) / 2);
	
	UIColor * color = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
	
	UIColor * color0 = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
	UIColor * color1 = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
	UIColor * color2 = [UIColor colorWithRed:0 green:0 blue:1 alpha:1];
	UIColor * color3 = [UIColor colorWithRed:0 green:1 blue:1 alpha:1];
	UIColor * color4 = [UIColor colorWithRed:1 green:0 blue:1 alpha:1];
	UIColor * color5 = [UIColor colorWithRed:1 green:1 blue:0 alpha:1];
	
	CGFloat colorsGL[] = {
        1.0, 0.0, 0.0, 1.0,		// Red - top left - colour for squareVertices[0]
        0.0, 1.0, 0.0, 1.0,		// Green - bottom left - squareVertices[1]
        0.0, 0.0, 1.0, 1.0,		// Blue - bottom right - squareVerticies[2]
        0.5, 0.5, 0.5, 1.0,		// Grey - top right- squareVerticies[3]
		0.3, 0.8, 0.2, 1.0,
		0.9, 0.4, 0.6, 1.0,
		0.4, 0.8, 0.3, 1.0,
		0.7, 0.9, 0.5, 1.0
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
	

	switch (ctrl.priType) {
		case kPrimitivePoint: {
			// MARK: point
			width = 3;
			[primitiveGL drawPoints:points pointAmount:4 inContext:context withColor:color1 width:width];
			[primitiveGL drawPointsInContext:context withColor:color2 width:5 
									  points:sPoint(point0), sPoint(point1), sPoint(point2), sPoint(point3), nil];
			
			[primitiveGL drawPoint:ctrl.pointTouchBegin inContext:context withColor:USER_COLOR width:ctrl.lineWidth];			
			break;
		}
		case kPrimitiveLine: {
			// MARK: line
			width = 5;
			pointStart = CGPointMake(10, 160);
			pointEnd = CGPointMake(110, 260);
			[primitiveGL drawLineFrom:pointStart to:pointEnd 
							inContext:context 
							withColor:color];
			
			color = color4;
			pointStart = CGPointMake(110, 160);
			pointEnd = CGPointMake(210, 260);
			[primitiveGL drawLineFrom:pointStart to:pointEnd inContext:context withColor:color width:width];
			
			width = 8;
			color = color3;
			pointStart = CGPointMake(210, 160);
			pointEnd = CGPointMake(310, 260);
			[primitiveGL drawLineFrom:pointStart to:pointEnd inContext:context withColor:color width:width];
					
			// draw lines
			width = 2;
			color = color1;
			points[0] = CGPointMake(10.0, 90.0);
			points[1] = CGPointMake(70.0, 60.0);
			points[2] = CGPointMake(130.0, 90.0);
			points[3] = CGPointMake(190.0, 60.0);
			points[4] = CGPointMake(250.0, 90.0);
			points[5] = CGPointMake(310.0, 60.0);
			[primitiveGL drawLines:points pointAmount:ARRAY_LENGTH(points) 
						 inContext:context 
						 withColor:color width:width
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
			[primitiveGL drawLinesInContext:context 
								  withColor:color width:width 
								  joinOrSeg:kLineJoin  
									sPoints:sPoint(point0), sPoint(point1), sPoint(point2), 
			 sPoint(point3), sPoint(point4), sPoint(point5), nil];
			
			[primitiveGL drawLineFrom:ctrl.pointTouchBegin to:ctrl.pointTouchEnd 
							inContext:context 
							withColor:USER_COLOR width:DEFAULT_LINE_WIDTH];			
			break;
		}
		case kPrimitiveArc: {
			// MARK: arc
			width = 5;
			color = color0;
			[primitiveGL drawPoint:pointCenter inContext:context withColor:color width:width];
			[primitiveGL drawLineFrom:pointCenter to:CGPointMake(pointCenter.x + 50, pointCenter.y) 
							inContext:context withColor:color width:DEFAULT_LINE_WIDTH];
			width = 2;
			color = color1;
			[primitiveGL drawArcAt:pointCenter radius:50 from:-90 to:90 clockwise:kArcClockwise inContext:context withColor:color];
			color = color2;
			[primitiveGL fillArcAt:pointCenter radius:50 from:-90 to:90 clockwise:kArcCounterClockwise 
						 inContext:context withColor:color gradient:nil];
			width = 4;
			color = color3;
			[primitiveGL drawArcAt:pointCenter radius:80 from:135 to:225 clockwise:kArcClockwise 
						 inContext:context withColor:color width:width];
			
			pointStart = CGPointMake(150, 50);
			pointEnd = CGPointMake(250, 150);
			width = 5;
			color = color0;
			[primitiveGL drawPoint:pointStart inContext:context withColor:color width:width];
			[primitiveGL drawPoint:pointEnd inContext:context withColor:color width:width];
			[primitiveGL drawLineFrom:pointStart to:pointEnd inContext:context withColor:color];
			width = 2;
			color = color1;
			[primitiveGL fillArcFrom:pointStart to:pointEnd radius:80 clockwise:kArcClockwise 
						   inContext:context withColor:color gradient:nil];
			color = color2;
			width = 4;
			[primitiveGL fillArcFrom:pointStart to:pointEnd radius:80 clockwise:kArcCounterClockwise
						   inContext:context withColor:nil gradient:colorsGL];
			
			if (CGRectContainsPoint(CGRectMake(0, 0, pointCenter.x * 2, pointCenter.y), ctrl.pointTouchBegin)) {
				[primitiveGL drawPoint:ctrl.pointTouchBegin inContext:context withColor:USER_COLOR width:width];
				[primitiveGL drawArcAt:ctrl.pointTouchBegin radius:20 + ctrl.lineWidth 
								  from:ctrl.angle to:ctrl.angle + 90 clockwise:kArcClockwise 
							 inContext:context withColor:USER_COLOR];
			} else {
				[primitiveGL drawPoint:ctrl.pointTouchBegin inContext:context withColor:USER_COLOR width:width];
				[primitiveGL drawPoint:ctrl.pointTouchEnd inContext:context withColor:USER_COLOR width:width];
				[primitiveGL drawArcFrom:ctrl.pointTouchBegin to:ctrl.pointTouchEnd 
								  radius:DISTANCE_BETWEEN_POINT(ctrl.pointTouchBegin, ctrl.pointTouchEnd) + ctrl.lineWidth 
							   clockwise:kArcClockwise 
							   inContext:context withColor:USER_COLOR];
			}			
			break;
		}
		case kPrimitiveBezier: {
			// MARK: bezier
//			[self comingsoon];
			width = 5;
			color = color0;
			CGPoint s = CGPointMake(30.0, 120.0);
			CGPoint e = CGPointMake(300.0, 120.0);
			CGPoint c1 = CGPointMake(120.0, 30.0);
			CGPoint c2 = CGPointMake(210.0, 210.0);
			[primitiveGL drawPoint:s inContext:context withColor:color width:width];
			[primitiveGL drawPoint:e inContext:context withColor:color width:width];
			
			kBezier bPoints = {s, e, c1, c2};
			color = color1;
			[primitiveGL drawBezierCurve:bPoints inContext:context withColor:color width:3];
			[primitiveGL drawPoint:c1 inContext:context withColor:color width:width];
			[primitiveGL drawPoint:c2 inContext:context withColor:color width:width];
			
			c1 = CGPointMake(10.0, 250.0);			
			kBezier bPoints1 = {s, e, c1, c1};
			color = color2;
			[primitiveGL drawBezierCurve:bPoints1 inContext:context withColor:color width:3];
			[primitiveGL drawPoint:c1 inContext:context withColor:color width:width];
			
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
			[primitiveGL drawPoint:s inContext:context withColor:USER_COLOR width:width];
			[primitiveGL drawPoint:e inContext:context withColor:USER_COLOR width:width];
			[primitiveGL drawPoint:c1 inContext:context withColor:USER_COLOR width:width];
			[primitiveGL drawPoint:c2 inContext:context withColor:USER_COLOR width:width];
			kBezier bPoints2 = {s, e, c1, c2};
			[primitiveGL drawBezierCurve:bPoints2 inContext:context withColor:USER_COLOR];
			break;
		}
		case kPrimitiveRect: {
			// MARK: rect
			color = color1;
			[primitiveGL drawRect:rect inContext:context withColor:color];
			width = 4;
			rect.origin.x -= 20;
			rect.origin.y -= 20;
			rect.size.width += 40;
			rect.size.height += 40;
			[primitiveGL drawRoundRect:rect radius:20 inContext:context withColor:color width:width];
			
			rect.origin.x += 40;
			rect.origin.y += 40;
			rect.size.width -= 80;
			rect.size.height -= 80;
			[primitiveGL fillRoundRect:rect radius:20 inContext:context withColor:color gradient:nil];
			
			color = color2;
			[primitiveGL drawRects:rects rectAmount:ARRAY_LENGTH(rects) inContext:context 
						 withColor:color width:width];
			for (int i = 0; i < ARRAY_LENGTH(rects); i++) {
				rects[i].origin.x += 10;
				rects[i].origin.y += 10;
				rects[i].size.width -= 20;
				rects[i].size.height -= 20;
			}
			[primitiveGL fillRects:rects rectAmount:ARRAY_LENGTH(rects) inContext:context withColor:nil gradient:colorsGL];
			
			color = color3;
			[primitiveGL drawRectsInContext:context withColor:color width:DEFAULT_LINE_WIDTH
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
			[primitiveGL fillRectsInContext:context withColor:color gradient:nil
									 sRects:sRect(rect0), sRect(rect1), sRect(rect2), sRect(rect3), nil];
			
			width = 3;
			rect = [ctrl rectByTouchDrag];
			[primitiveGL drawRect:rect inContext:context withColor:USER_COLOR];
			if (rect.size.width > 30 && rect.size.height > 30) {
				rect.origin.x += 15;
				rect.origin.y += 15;
				rect.size.width -= 30;
				rect.size.height -= 30;				
				[primitiveGL fillRect:rect inContext:context withColor:nil gradient:colorsGL];
			}						
			break;
		}
		case kPrimitiveEllipse: {
			// MARK: ellipse
			color = color1;
			[primitiveGL drawEllipse:rect inContext:context withColor:color];
			width = 4;
			rect.origin.x -= 20;
			rect.origin.y -= 20;
			rect.size.width += 40;
			rect.size.height += 40;
			[primitiveGL drawEllipse:rect inContext:context withColor:color width:width];
			
			rect.origin.x += 40;
			rect.origin.y += 40;
			rect.size.width -= 80;
			rect.size.height -= 80;
			[primitiveGL fillEllipse:rect inContext:context withColor:color gradient:nil];
			
			color = color2;
			[primitiveGL drawEllipses:rects rectAmount:ARRAY_LENGTH(rects) inContext:context withColor:color width:width];
			for (int i = 0; i < ARRAY_LENGTH(rects); i++) {
				rects[i].origin.x += 10;
				rects[i].origin.y += 10;
				rects[i].size.width -= 20;
				rects[i].size.height -= 20;
			}
			[primitiveGL fillEllipses:rects rectAmount:ARRAY_LENGTH(rects) inContext:context withColor:nil gradient:colorsGL];
			
			color = color3;
			[primitiveGL drawEllipsesInContext:context withColor:color width:DEFAULT_LINE_WIDTH
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
			[primitiveGL fillEllipsesInContext:context withColor:color gradient:nil
									 sRects:sRect(rect0), sRect(rect1), sRect(rect2), sRect(rect3), nil];
			
			width = 3;
			rect = [ctrl rectByTouchDrag];
			[primitiveGL drawEllipse:rect inContext:context withColor:USER_COLOR];
			if (rect.size.width > 30 && rect.size.height > 30) {
				rect.origin.x += 15;
				rect.origin.y += 15;
				rect.size.width -= 30;
				rect.size.height -= 30;				
				[primitiveGL fillEllipse:rect inContext:context withColor:nil gradient:colorsGL];
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
			[primitiveGL drawPolygonByPoints:points pointAmount:ARRAY_LENGTH(points) inContext:context withColor:color4];
			
			color = color0;
			[primitiveGL drawPoint:pointCenter inContext:context withColor:color width:3];
			color = color1;
			[primitiveGL drawPoint:CGPointMake(160, 240) inContext:context withColor:color1];			
			[primitiveGL drawRegularPolygon:3 at:pointCenter radius:10 angle:ctrl.angle inContext:context withColor:color];
			[primitiveGL drawRegularPolygon:4 at:pointCenter radius:20 angle:-ctrl.angle inContext:context 
								  withColor:color width:3];
			[primitiveGL drawRegularPolygon:5 at:pointCenter radius:30 angle:ctrl.angle inContext:context withColor:color];
			[primitiveGL drawRegularPolygon:6 at:pointCenter radius:40 angle:-ctrl.angle inContext:context 
								  withColor:color width:4];
			[primitiveGL drawRegularPolygon:7 at:pointCenter radius:50 angle:ctrl.angle inContext:context withColor:color];
			[primitiveGL drawRegularPolygon:8 at:pointCenter radius:60 angle:-ctrl.angle inContext:context 
								  withColor:color width:5];
			[primitiveGL drawRegularPolygon:9 at:pointCenter radius:70 angle:ctrl.angle inContext:context withColor:color];
			[primitiveGL drawRegularPolygon:10 at:pointCenter radius:80 angle:-ctrl.angle inContext:context 
								  withColor:color width:2];
			[primitiveGL drawRegularPolygon:11 at:pointCenter radius:90 angle:ctrl.angle inContext:context 
								  withColor:color width:4];			
			
			pointStart = CGPointMake(70, 70);
			[primitiveGL fillRegularPolygon:8 at:pointStart radius:60 angle:22.5 
								  inContext:context 
								  withColor:nil gradient:colorsGL];
			
			if (!CGPointEqualToPoint(ctrl.pointTouchBegin, pointCenter)) {
				[primitiveGL drawPoint:ctrl.pointTouchBegin inContext:context withColor:USER_COLOR width:3];
				[primitiveGL drawRegularPolygon:(3 + ctrl.lineWidth / 5) at:ctrl.pointTouchBegin 
										 radius:(10 + ctrl.lineWidth * 2) angle:(ctrl.angle * 1) 
									  inContext:context 
									  withColor:USER_COLOR];
			}
			break;
		}
		case kPrimitiveStar: {
			// MARK: star
			color = color0;
			[primitiveGL drawPoint:pointCenter inContext:context withColor:color width:3];
			color = color1;
			[primitiveGL drawPoint:pointCenter inContext:context withColor:color1];
			[primitiveGL drawStar:24 at:pointCenter radius:100 angle:ctrl.angle inContext:context withColor:color];
			[primitiveGL fillStar:9 at:pointCenter radius:100 angle:ctrl.angle 
						inContext:context 
						withColor:color gradient:nil];
			
			width = 3;
			color = color2;
			pointStart = CGPointMake(60, 60);
			[primitiveGL drawStar:5 at:pointStart radius:50 angle:(ctrl.angle * 2) inContext:context 
						withColor:color width:width];
			pointStart.x = 260;
			[primitiveGL drawStar:6 at:pointStart radius:50 angle:(-ctrl.angle * 2) inContext:context 
						withColor:color width:width];
			pointStart.y = 360;
			color = color3;
			[primitiveGL fillStar:7 at:pointStart radius:50 angle:(ctrl.angle * 2) inContext:context 
						withColor:nil gradient:colorsGL];
			pointStart.x = 60;
			[primitiveGL fillStar:8 at:pointStart radius:50 angle:(-ctrl.angle * 2) inContext:context withColor:color gradient:nil];
			
			if (!CGPointEqualToPoint(ctrl.pointTouchBegin, pointCenter)) {
				radius = 10 + ctrl.lineWidth * 2;
				[primitiveGL drawStar:(3 + ctrl.lineWidth / 5) at:ctrl.pointTouchBegin radius:radius angle:(ctrl.angle * 1) 
							inContext:context withColor:USER_COLOR];
				if (radius > 20) {
					[primitiveGL fillStar:(3 + ctrl.lineWidth / 5) at:ctrl.pointTouchBegin 
								   radius:radius - 20 angle:(-ctrl.angle * 2) 
								inContext:context withColor:USER_COLOR gradient:nil];
				}
			}
			break;
		}
		case kPrimitiveFan: {
			// MARK: fan
			radius = 60;			
			[primitiveGL fillFanAt:pointCenter radius:radius from:0 to:359 clockwise:kArcClockwise 
						 inContext:context withColor:color gradient:nil];
			color = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
			width = 3;
			[primitiveGL drawFanAt:pointCenter radius:radius from:0 to:359 clockwise:kArcClockwise 
						 inContext:context withColor:color width:width];
			[primitiveGL fillFanAt:pointCenter radius:radius - 2 from:0 to:359 clockwise:kArcClockwise 
						 inContext:context withColor:color5 gradient:nil];
			[primitiveGL fillFanAt:pointCenter radius:radius - 6 from:60 to:120 clockwise:kArcClockwise 
						 inContext:context withColor:color gradient:nil];
			[primitiveGL fillFanAt:pointCenter radius:radius - 6 from:180 to:240 clockwise:kArcClockwise 
						 inContext:context withColor:color gradient:nil];
			[primitiveGL fillFanAt:pointCenter radius:radius - 6 from:300 to:360 clockwise:kArcClockwise 
						 inContext:context withColor:color gradient:nil];
			[primitiveGL fillFanAt:pointCenter radius:18 from:0 to:359 clockwise:kArcClockwise 
						 inContext:context withColor:color5 gradient:nil];
			[primitiveGL fillFanAt:pointCenter radius:10 from:0 to:359 clockwise:kArcClockwise 
						 inContext:context withColor:color gradient:nil];
			
			float alphaValue = fabs(1 - (ctrl.angle % 20) * 1.0 / 10);
			CLAMP(alphaValue, 0.1, 0.8);
			color = [UIColor colorWithRed:1 green:0 blue:0 alpha:alphaValue];
			[primitiveGL fillFanAt:pointCenter radius:radius from:270 to:(270 + ctrl.angle) clockwise:kArcCounterClockwise 
						 inContext:context withColor:color gradient:nil];
			
			if (!CGPointEqualToPoint(ctrl.pointTouchBegin, pointCenter)) {
				[primitiveGL drawPoint:ctrl.pointTouchBegin inContext:context withColor:USER_COLOR width:5];
				[primitiveGL fillFanAt:ctrl.pointTouchBegin radius:(50 + ctrl.lineWidth) 
								  from:(ctrl.angle * 10) to:(ctrl.angle * 10 + 60) clockwise:kArcClockwise 
							 inContext:context withColor:nil gradient:colorsGL];
				[primitiveGL drawFanAt:ctrl.pointTouchBegin radius:(50 + ctrl.lineWidth) 
								  from:(ctrl.angle * 10) to:(ctrl.angle * 10 + 60) clockwise:kArcClockwise 
							 inContext:context withColor:USER_COLOR width:DEFAULT_LINE_WIDTH];
			}			
			break;
		}
		case kPrimitiveGradient: {
			// MARK: gradient fill
			rect = CGRectMake(50, 20, 100, 100);
			[primitiveGL fillRect:rect inContext:context withColor:nil gradient:colorsGL];
			rect = CGRectMake(80, 150, 100, 100);			
			[primitiveGL fillRect:rect inContext:context withColor:nil gradient:colorsGL];
			rect = CGRectMake(110, 280, 100, 100);
			[primitiveGL fillRect:rect inContext:context withColor:nil gradient:colorsGL];			
			rect = [ctrl rectByTouchDrag];
			[primitiveGL fillRect:rect inContext:context withColor:nil gradient:colorsGL];			
			break;
		}
		case kPrimitiveImage: {
			// MARK: image
			NSInteger tempAngle = ctrl.angle;
			rect = CGRectMake(0, 0, 320, 416);
			[primitiveGL fillImageNamed:IMAGE_BOARD inRect:rect inContext:context withTrans:0.2];
			for (int i = 0; i < 4; i++) {
				[primitiveGL drawImageNamed:IMAGE_SPRITE at:points[i] alignment:kAlignmentHcenterVcenter 
								  inContext:context 
								  withTrans:0.5 flip:kFlipNone rotate:tempAngle scaleX:0.5 scaleY:0.5];
				[primitiveGL drawPoint:points[i] inContext:context withColor:color0 width:3];
			}
			
			pointStart = CGPointMake(10, 10);
			[primitiveGL drawImageNamed:IMAGE_CHECK at:pointStart alignment:kAlignmentLeftTop 
							  inContext:context 
							  withTrans:0.1 flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
			[primitiveGL drawPoint:pointStart inContext:context withColor:color0 width:3];
			pointStart = CGPointMake(160, 10);
			[primitiveGL drawImageNamed:IMAGE_CHECK at:pointStart alignment:kAlignmentHcenterTop 
							  inContext:context 
							  withTrans:0.2 flip:kFlipX rotate:0 scaleX:1 scaleY:1];
			[primitiveGL drawPoint:pointStart inContext:context withColor:color0 width:3];
			pointStart = CGPointMake(310, 10);
			[primitiveGL drawImageNamed:IMAGE_CHECK at:pointStart alignment:kAlignmentRightTop 
							  inContext:context 
							  withTrans:0.3 flip:kFlipY rotate:0 scaleX:1 scaleY:1];
			[primitiveGL drawPoint:pointStart inContext:context withColor:color0 width:3];
			pointStart = CGPointMake(10, 208);
			[primitiveGL drawImageNamed:IMAGE_CHECK at:pointStart alignment:kAlignmentLeftVcenter 
							  inContext:context 
							  withTrans:0.4 flip:kFlipXY rotate:0 scaleX:1 scaleY:1];
			[primitiveGL drawPoint:pointStart inContext:context withColor:color0 width:3];
			pointStart = CGPointMake(160, 208);
			[primitiveGL drawImageNamed:IMAGE_CHECK at:pointStart alignment:kAlignmentHcenterVcenter 
							  inContext:context 
							  withTrans:0.5 flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
			[primitiveGL drawPoint:pointStart inContext:context withColor:color0 width:3];
			pointStart = CGPointMake(310, 208);
			[primitiveGL drawImageNamed:IMAGE_CHECK at:pointStart alignment:kAlignmentRightVcenter 
							  inContext:context 
							  withTrans:0.6 flip:kFlipX rotate:0 scaleX:1 scaleY:1];
			[primitiveGL drawPoint:pointStart inContext:context withColor:color0 width:3];
			pointStart = CGPointMake(10, 406);
			[primitiveGL drawImageNamed:IMAGE_CHECK at:pointStart alignment:kAlignmentLeftBottom 
							  inContext:context 
							  withTrans:0.7 flip:kFlipY rotate:0 scaleX:1 scaleY:1];
			[primitiveGL drawPoint:pointStart inContext:context withColor:color0 width:3];
			pointStart = CGPointMake(160, 406);
			[primitiveGL drawImageNamed:IMAGE_CHECK at:pointStart alignment:kAlignmentHcenterBottom 
							  inContext:context 
							  withTrans:0.8 flip:kFlipXY rotate:0 scaleX:1 scaleY:1];
			[primitiveGL drawPoint:pointStart inContext:context withColor:color0 width:3];
			pointStart = CGPointMake(310, 406);
			[primitiveGL drawImageNamed:IMAGE_CHECK at:pointStart alignment:kAlignmentRightBottom 
							  inContext:context 
							  withTrans:0.9 flip:kFlipNone rotate:0 scaleX:1 scaleY:1];
			[primitiveGL drawPoint:pointStart inContext:context withColor:color0 width:3];
			
			rect = [ctrl rectByTouchDrag];
			if (!CGPointEqualToPoint(ctrl.pointTouchBegin, pointCenter) 
				&& (CGPointEqualToPoint(ctrl.pointTouchEnd, pointCenter) || rect.size.width < 50 || rect.size.height < 50)) {
				float scale = (10 - ctrl.lineWidth) / 10;				
				[primitiveGL drawImageNamed:IMAGE_ICON at:ctrl.pointTouchBegin alignment:kAlignmentHcenterVcenter 
								  inContext:context
								  withTrans:0.75 flip:kFlipNone rotate:(ctrl.angle * 3) scaleX:scale scaleY:scale];
				[primitiveGL drawPoint:ctrl.pointTouchBegin inContext:context withColor:USER_COLOR width:3];
			} else {
				[primitiveGL fillImageNamed:IMAGE_ICON inRect:rect inContext:context withTrans:0.5];
				[primitiveGL drawRect:rect inContext:context withColor:USER_COLOR];
			}
			break;
		}
		case kPrimitivePDF: {
			// MARK: pdf
			[self comingsoon];
			break;
		}
		case kPrimitiveText: {
			// MARK: text
			[self comingsoon];
			break;
		}
		case kPrimitiveGlyphs:
			// MARK: glyphs
			[self comingsoon];
			break;
			
		case kPrimitiveOthers:
			// MARK: others
			[self comingsoon];
			break;
	}

#pragma mark -
	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];	
	
}

// Release resources when they are no longer needed.
- (void)dealloc
{
	if([EAGLContext currentContext] == context) {
		[EAGLContext setCurrentContext:nil];
	}
	
	[context release];
	context = nil;
	
	[super dealloc];
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

- (void)comingsoon {
	[primitiveGL drawImageNamed:IMAGE_WAIT at:CGPointMake(self.frame.size.width / 2, (self.frame.size.height - 64) / 2) 
					  alignment:kAlignmentHcenterVcenter
					  inContext:context];
}

@end
