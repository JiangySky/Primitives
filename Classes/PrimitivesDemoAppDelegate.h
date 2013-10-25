//
//  PrimitivesDemoAppDelegate.h
//  PrimitivesDemo
//
//  Created by Jiangy on 11-5-14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootController;


@interface PrimitivesDemoAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *					window;
	UINavigationController *	nav;
}

@property (nonatomic, retain) IBOutlet UIWindow *					window;
@property (nonatomic, retain) IBOutlet UINavigationController *		nav;

- (void)helpInfo;

@end


