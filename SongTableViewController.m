//
//  SongTableViewController.m
//  StreamingApp
//
//  Created by Tyler Much on 9/1/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "SongTableViewController.h"

@interface SongTableViewController ()

@end

@implementation SongTableViewController
{
    NSString *givenAlbum;
    NSString *givenArtist;
}


- (void)refreshTable {
    [self populateSongsTableFromNetworkForAlbum:givenAlbum fromArtist:givenArtist];
}

- (void)setAlbumAndArtistFromDictionary:(NSDictionary *)dict {
    givenArtist = [dict objectForKey:@"artist"];
    givenAlbum = [dict objectForKey:@"album"];
    self.title = givenAlbum;
    [self refreshTable];
}

@end
