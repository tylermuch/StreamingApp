//
//  AlbumTVC.h
//  StreamingApp
//
//  Created by Tyler Much on 9/24/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "ParentTableViewController.h"
#import "StreamingAppUtil.h"
#import "AlbumCell.h"

@interface AlbumTVC : ParentTableViewController

@property (nonatomic, strong, readonly) NSString *givenArtist;

@end
