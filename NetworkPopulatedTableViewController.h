//
//  NetworkPopulatedTableViewController.h
//  StreamingApp
//
//  Created by Tyler Much on 9/1/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetworkPopulatedTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *tableItems;

- (void)populateArtistTableFromNetwork;
- (void)populateAlbumTableFromNetworkForArtist:(NSString *)artist;
- (void)populateSongsTableFromNetworkForAlbum:(NSString *)album fromArtist:(NSString *)artist;

@end
