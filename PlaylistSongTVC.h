//
//  PlaylistSongTVC.h
//  StreamingApp
//
//  Created by Tyler Much on 9/24/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "ParentTableViewController.h"
#import "TrackPlaylist.h"
#import "PlaylistSongCell.h"

@interface PlaylistSongTVC : ParentTableViewController

@property (nonatomic, strong, readonly) TrackPlaylist *givenPlaylist;

@end
