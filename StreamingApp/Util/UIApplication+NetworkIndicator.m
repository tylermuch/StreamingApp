//
//  UIApplication+NetworkIndicator.m
//  StreamingApp
//
//  Created by Tyler Much on 9/2/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "UIApplication+NetworkIndicator.h"

/*
    If the activityCount value is less than or equal to zero then the
    network activity indicator will be off. If it is greater than zero then
    the network activity indicator will be on.
 */
static NSInteger *activityCount = 0;

@implementation UIApplication (NetworkIndicator)

- (void)showNetworkActivityIndicator {
    if ([[UIApplication sharedApplication] isStatusBarHidden]) return;
    @synchronized ([UIApplication sharedApplication]) {
        if (activityCount == 0) {
            [self setNetworkActivityIndicatorVisible:YES];
        }
        activityCount++;
    }
}

- (void)hideNetworkActivityIndicator {
    if ([[UIApplication sharedApplication] isStatusBarHidden]) return;
    @synchronized ([UIApplication sharedApplication]) {
        activityCount--;
        if (activityCount <= 0) {
            [self setNetworkActivityIndicatorVisible:NO];
            activityCount=0;
        }
    }
}

@end
