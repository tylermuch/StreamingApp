//
//  SpotifyArtistTVC.m
//  StreamingApp
//
//  Created by Tyler  Much on 10/3/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "SpotifyArtistTVC.h"

@implementation SpotifyArtistTVC

- (void)populateTable {
    
}

- (void)setArtist:(SPTPartialArtist *)artist {
    _givenArtist = artist;
    self.title = artist.name;
    [self populateTable];
}

@end
