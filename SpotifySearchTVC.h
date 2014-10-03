//
//  SpotifySearchTVC.h
//  StreamingApp
//
//  Created by Tyler Much on 9/28/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "ParentTableViewController.h"

@interface SpotifySearchTVC : ParentTableViewController

@property (nonatomic, strong, readonly) UISearchController *searchController;
@property (nonatomic, strong, readonly) NSMutableArray *searchResultsArtists; // of SPTPartialArtist
@property (nonatomic, strong, readonly) NSMutableArray *searchResultsAlbums;  // of SPTPartialAlbum
@property (nonatomic, strong, readonly) NSMutableArray *searchResultsSongs;   // of SPTPartialTrack

@end