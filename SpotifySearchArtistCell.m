//
//  SpotifySearchArtistCell.m
//  StreamingApp
//
//  Created by Tyler Much on 9/29/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "SpotifySearchArtistCell.h"
#import "SpotifySearchTVC.h"

extern NSString * const ARTIST_SELECT_SEQUE;

@implementation SpotifySearchArtistCell

- (void)onHeld {
    NSLog(@"Artist cell held");
}

- (void)onSelected {
    NSLog(@"Artist cell selected");
    [self.parentTVC performSegueWithIdentifier:ARTIST_SELECT_SEQUE sender:self];
}

@end
