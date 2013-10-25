//
//  RootController.m
//  PrimitivesDemo
//
//  Created by Jiangy on 11-5-14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootController.h"
#import "PrimitivesDemoAppDelegate.h"
#import "PrimitiveView.h"

@implementation RootController

@synthesize arrayPriTitle;
@synthesize arrayPriIcon;
@synthesize arrayPriDetail;


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		// Initialization code
	}
	return self;
}

- (void)viewDidLoad {
	self.title = @"Primitive List";
	arrayPriTitle = [[NSArray alloc] initWithObjects:@"Point", @"Line", @"Arc", @"Bezier", 
					   @"Rect", @"Ellipse", @"Polygon", @"Star", @"Fan", @"Gradient", 
					   @"Image", @"PDF", @"Text", @"Others", nil];
	
	arrayPriDetail = [[NSDictionary alloc] initWithObjectsAndKeys:
					  @"Draw at point with color. Also, width. As OpenGL, points[] with amount or point0,...,nil is enable.",
					  @"Point",
					  @"Draw line from point to point, or lines by points[] with amount or point0,...,nil. All with color. Also width, cap, join, solidOrDotted, joinOrSeg.",
					  @"Line",
					  @"Draw or fill, from point to point, or at center with startAngle and endAngle. All with radius and color. Also width, cap, join, solidOrDotted for draw.",
					  @"Arc",
					  @"Draw with kBezier{s,e,c1,c2} and color, Also width, cap, join, solidOrDotted. Quadratic when c1 equal to c2.",
					  @"Bezier",
					  @"Draw or fill, rect or rects by rects[] with amount or rect0,...nil. All with color. Also width, cap, join, solidOrDotted for draw. Besides, round rect with corner radius.",
					  @"Rect",
					  @"Draw or fill, ellipse or ellipses by rects[] with amount or rect0,...nil. All with color. Also width, cap, join, solidOrDotted for draw.",
					  @"Ellipse",
					  @"Draw or fill, polygon by points[] with amount and color. Also width, cap, join, solidOrDotted for draw, pathMode for fill. Besides, regular polygon with sideAmount center radius angle and others.",
					  @"Polygon",
					  @"Draw or fill, regular star with pointAmount center angle and color. Also width, cap, join, solidOrDotted for draw, pathMode for fill.",
					  @"Star",
					  @"Draw or fill, at center with radius startAngle endAngle clockwise and color. Also width, cap, join, solidOrDotted for draw",
					  @"Fan",
					  @"Fill by colors[] with amount or color0,...,nil or components[] with amount. All with style.",
					  @"Gradient",
					  @"Draw by image or image name at position or fill in rect with fillStype. Also with alignment alpha flip rotate scaleX and scaleY",
					  @"Image",
					  @"Draw at position or in rect",
					  @"PDF",
					  @"Draw text or glyphs with amount in rect. Also with color font size strokeColor and pathMode",
					  @"Text",
					  @"Something later",
					  @"Others",
					  nil];
	
//	UIImage * icon = [UIImage imageNamed:IMAGE_CHECK];
//	NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
//	for (int i = 0; i < [arrayPriTitle count]; i++) {
//		[array addObject:icon];
//	}
//	arrayPriIcon = [NSArray arrayWithArray:array];
//	[array release];
//	[icon release];
	
//	buttonInfo = [UIButton buttonWithType:UIButtonTypeInfoDark];
//	buttonInfo.frame = CGRectMake(300, 0, buttonInfo.frame.size.width, buttonInfo.frame.size.height);
//	[self.view addSubview:buttonInfo];
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

- (void)dealloc {
	[arrayPriTitle release];
	[arrayPriIcon release];
    [super dealloc];
}

#pragma mark -
#pragma mark === UITableView delegate & date source methods ===
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [arrayPriTitle count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
									   reuseIdentifier:kCellIdentifier] autorelease];
	}
	
	NSUInteger row = [indexPath row];
	cell.textLabel.text = [arrayPriTitle objectAtIndex:row];
//	cell.image = (UIImage *)[arrayPriIcon objectAtIndex:row];
	cell.detailTextLabel.text = [arrayPriDetail objectForKey:cell.textLabel.text];
	cell.detailTextLabel.adjustsFontSizeToFitWidth = NO;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	NSString * ttl = [arrayPriTitle objectAtIndex:row];
	PrimitiveController * pct = [[PrimitiveController alloc] initWithType:row 
																	title:ttl
																   detail:[arrayPriDetail objectForKey:ttl]];
	PrimitivesDemoAppDelegate * delegate = [[UIApplication sharedApplication] delegate];
	
	[delegate.nav pushViewController:pct animated:YES];

}

@end
