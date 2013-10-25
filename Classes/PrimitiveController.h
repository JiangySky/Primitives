//
//  PrimitiveController.h
//  PrimitivesDemo
//
//  Created by Jiangy on 11-5-14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrimitiveView.h"
#import "EAGLView.h"

#define FPS					20

#define USER_COLOR			[UIColor colorWithRed:0 green:0 blue:0 alpha:1]
#define IMAGE_SPRITE		@"sprite.png"
#define IMAGE_BOARD			@"board.png"
#define IMAGE_CHECK			@"check.png"
#define IMAGE_ICON			@"icon.png"
#define IMAGE_WAIT			@"wait.png"

enum PrimitivesType {
	kPrimitivePoint,
	kPrimitiveLine,
	kPrimitiveArc,
	kPrimitiveBezier,
	kPrimitiveRect,
	kPrimitiveEllipse,
	kPrimitivePolygon,
	kPrimitiveStar,
	kPrimitiveFan,
	kPrimitiveGradient,
	kPrimitiveImage,
	kPrimitivePDF,
	kPrimitiveText,
	kPrimitiveGlyphs,
	kPrimitiveOthers,
};


@interface PrimitiveController : UIViewController <UIScrollViewDelegate> {
	EAGLView *				glView;
	PrimitiveView *			priView;
	UIButton *				buttonSwitch;
	UILabel *				label;
	
	NSString *				detail;
	NSInteger				priType;
	CGPoint					pointTouchBegin;
	CGPoint					pointTouchEnd;
	NSInteger				angle;
	CGFloat					lineWidth;
	CGRect					rectContent;
	NSTimeInterval			touchBeginTime;
	BOOL					isGL;
}

@property (nonatomic, retain) IBOutlet EAGLView *			glView;
@property (nonatomic, retain) IBOutlet PrimitiveView *		priView;
@property (nonatomic, retain) IBOutlet UIButton *			buttonSwitch;
@property (nonatomic, retain) IBOutlet UILabel *			label;

@property (nonatomic, retain) NSString *					detail;
@property NSInteger				priType;
@property CGPoint				pointTouchBegin;
@property CGPoint				pointTouchEnd;
@property NSInteger				angle;
@property CGFloat				lineWidth;
@property CGRect				rectContent;
@property NSTimeInterval		touchBeginTime;


- (id)initWithType:(NSInteger)type title:(NSString *)ttl detail:(NSString *)dtl;
- (void)showInfo:(NSTimer *)timer;
- (IBAction)switchView:(id)sender;

- (void)update:(NSTimer *)timer;
- (CGRect)rectByTouchDrag;

@end
