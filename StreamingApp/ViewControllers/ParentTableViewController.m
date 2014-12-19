//
//  ParentTableViewController.m
//  StreamingApp
//
//  Created by Tyler Much on 9/23/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "ParentTableViewController.h"

@implementation ParentTableViewController

- (void)viewDidLoad {
    self.tableItems = [[NSMutableArray alloc] init];
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePressHoldFrom:)];
    [self.tableView addGestureRecognizer:gesture];
}

- (void)handlePressHoldFrom:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint holdLocation = [recognizer locationInView:self.tableView];
        NSIndexPath *heldIndexPath = [self.tableView indexPathForRowAtPoint:holdLocation];
        [self tableView:self.tableView didHoldRowAtIndexPath:heldIndexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ParentTableViewCell class]]) {
        ParentTableViewCell *cell = (ParentTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell onSelected];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView didHoldRowAtIndexPath:(NSIndexPath *)indexPath {
    id cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ParentTableViewCell class]]) {
        ParentTableViewCell *cell = (ParentTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell onHeld];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableItems count];
}
@end
