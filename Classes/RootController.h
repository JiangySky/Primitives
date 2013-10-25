//
//  RootController.h
//  PrimitivesDemo
//
//  Created by Jiangy on 11-5-14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrimitiveController.h"

#define kCellIdentifier		@"PrimitiveDemo.CellIdentifier"

@interface RootController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
	NSArray *			arrayPriTitle;
	NSArray *			arrayPriIcon;
	NSDictionary *		arrayPriDetail;
}

@property (nonatomic, retain) NSArray *				arrayPriTitle;
@property (nonatomic, retain) NSArray *				arrayPriIcon;
@property (nonatomic, retain) NSDictionary *		arrayPriDetail;

@end
