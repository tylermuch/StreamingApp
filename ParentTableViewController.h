//
//  ParentTableViewController.h
//  StreamingApp
//
//  Created by Tyler Much on 9/23/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentTableViewCell.h"

@interface ParentTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *tableItems;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didHoldRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)handlePressHoldFrom:(UILongPressGestureRecognizer *)recognizer;
@end
