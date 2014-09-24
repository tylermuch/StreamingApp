//
//  ParentTableViewCell.h
//  StreamingApp
//
//  Created by Tyler Much on 9/23/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParentTableViewCell : UITableViewCell

@property (nonatomic) UITableViewController *parentTVC;

- (id)initWithParentTVC:(UITableViewController *)parent reuseIdentifier:(NSString *)reuseIdentifier;
- (void)onSelected;
- (void)onHeld;

@end
