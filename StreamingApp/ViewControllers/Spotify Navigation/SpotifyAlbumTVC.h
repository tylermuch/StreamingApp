//
//  SpotifySongTVC.h
//  StreamingApp
//
//  Created by Tyler  Much on 10/3/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "ParentTableViewController.h"
#import <Spotify/Spotify.h>

@interface SpotifyAlbumTVC : ParentTableViewController

@property (nonatomic, strong, readonly) SPTPartialAlbum *givenAlbum;

@end