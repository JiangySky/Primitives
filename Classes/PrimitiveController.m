//
//  PrimitiveController.m
//  PrimitivesDemo
//
//  Created by Jiangy on 11-5-14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PrimitiveController.h"


@implementation PrimitiveController

@synthesize glView;
@synthesize priView;
@synthesize buttonSwitch;
@synthesize label;

@synthesize detail;
@synthesize priType;
@synthesize pointTouchBegin;
@synthesize pointTouchEnd;
@synthesize angle;
@synthesize lineWidth;
@synthesize rectContent;
@synthesize touchBeginTime;


#pragma mark -

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad {
	UIBarButtonItem * infoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
																				 target:self 
																				 action:@selector(showInfo:)];
	self.navigationItem.rightBarButtonItem = infoButton;
	[infoButton release];
	
	[glView initWithController:self];
	[priView initWithController:self];
	
	isGL = NO;
	label.text = @"ToGL";
}

-(void)viewWillAppear:(BOOL)animated {
	
	[NSTimer scheduledTimerWithTimeInterval:1.0 / FPS target:self selector:@selector(update:) userInfo:nil repeats:YES];
}

- (void)dealloc {
	[glView release];
	[priView release];
    [super dealloc];
}

#pragma mark -

- (id)initWithType:(NSInteger)type title:(NSString *)ttl detail:(NSString *)dtl {
	if (self = [super init]) {
		priType = type;
		detail = dtl;
		self.title = ttl;
	}
	
	return [self autorelease];
}

- (void)showInfo:(NSTimer *)timer {
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil 
													 message:detail 
													delegate:self 
										   cancelButtonTitle:@"Done" 
										   otherButtonTitles:nil];
	
	
	[alert show];
	[alert release];
}

- (IBAction)switchView:(id)sender {
	[UIView beginAnimations:@"View Flip" context:nil];
	[UIView setAnimationDuration:1.25];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	UIView * coming = nil;
	UIView * going = nil;
	UIViewAnimationTransition transition;
	
	if (isGL) {	
		coming = priView;
		going = glView;
		transition = UIViewAnimationTransitionFlipFromLeft;
		[glView stopAnimation];
	} else {
		coming = glView;
		going = priView;
		transition = UIViewAnimationTransitionFlipFromLeft;
		[glView startAnimation];
	}
	
	[UIView setAnimationTransition: transition forView:self.view cache:YES];

	[self.view sendSubviewToBack:going];
	[self.view bringSubviewToFront:coming];
	
	[UIView commitAnimations];

	isGL ^= YES;
}

#pragma mark -

- (void)update:(NSTimer *)timer {
	angle = (++angle) % 360;
	if (touchBeginTime > 0) {
		lineWidth++;
	}
	
	if (!isGL) {
		[priView setNeedsDisplay];
	}	
}

- (CGRect)rectByTouchDrag {
	return CGRectMake(MIN(pointTouchBegin.x, pointTouchEnd.x), 
					  MIN(pointTouchBegin.y, pointTouchEnd.y), 
					  fabs(pointTouchBegin.x - pointTouchEnd.x), 
					  fabs(pointTouchBegin.y - pointTouchEnd.y));	
}

#pragma mark -

- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
	if (recognizer.state == UITouchPhaseEnded) {
		touchBeginTime = 0;
	}
}

- (void)pinch:(UIPinchGestureRecognizer *)recognizer {
	int myScale;
	if (recognizer.scale > 1) {
		myScale = 10 * (recognizer.scale / 3 + 1);
	} else {
		myScale = -10 * ((1 / recognizer.scale) / 3 + 1);
	}
	
	if (rectContent.size.width + myScale * 2 >= 20 && rectContent.size.width + myScale * 2 <= 320 * 5) {
		rectContent.origin.x -= myScale;
		rectContent.origin.y -= myScale;
		rectContent.size.width += myScale * 2;
		rectContent.size.height += myScale * 2;	
	}
}

#pragma mark -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch * touch = [touches anyObject];
	if (touch && touch.phase == UITouchPhaseBegan) {
		if (isGL) {
			pointTouchBegin = [touch locationInView:glView];
		} else {
			pointTouchBegin = [touch locationInView:priView];
		}
		if (touchBeginTime == 0) {
			touchBeginTime = touch.timestamp;
		}
		lineWidth = touch.timestamp - touchBeginTime;
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch * touch = [touches anyObject];
	if (touch && touch.phase == UITouchPhaseMoved) {
		if (isGL) {
			pointTouchEnd = [touch locationInView:glView];
		} else {
			pointTouchEnd = [touch locationInView:priView];
		}
		if (!CGRectEqualToRect(rectContent, CGRectZero)) {
			rectContent.origin.x += (pointTouchEnd.x - pointTouchBegin.x);
			rectContent.origin.y += (pointTouchEnd.y - pointTouchBegin.y);
		}		
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch * touch = [touches anyObject];
	if (touch && touch.phase == UITouchPhaseEnded) {
		if (isGL) {
			pointTouchEnd = [touch locationInView:glView];
		} else {
			pointTouchEnd = [touch locationInView:priView];
		}
		touchBeginTime = 0;
	}
}


@end
