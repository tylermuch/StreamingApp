//
//  SongTVC.h
//  StreamingApp
//
//  Created by Tyler Much on 9/24/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "ParentTableViewController.h"
#import "StreamingAppUtil.h"
#import "SongCell.h"

@interface SongTVC : ParentTableViewController

@property (nonatomic, strong, readonly) NSString *givenArtist;
@property (nonatomic, strong, readonly) NSString *givenAlbum;

@end
