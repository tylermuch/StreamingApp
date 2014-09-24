//
//  ParentTableViewCell.m
//  StreamingApp
//
//  Created by Tyler Much on 9/23/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "ParentTableViewCell.h"

@implementation ParentTableViewCell

- (id)initWithParentTVC:(UITableViewController *)parent reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.parentTVC = parent;
    }
    return self;
}

- (void)onHeld {
    [self doesNotRecognizeSelector:_cmd];
}

- (void)onSelected {
    [self doesNotRecognizeSelector:_cmd];
}

@end
