//
//  ArtistCell.m
//  StreamingApp
//
//  Created by Tyler  Much on 10/4/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "ArtistCell.h"
#import "SpotifySearchTVC.h"
#include "debug.h"

@implementation ArtistCell

extern NSString * const ARTIST_SELECT_SEGUE;

- (void)onHeld {
    UI_TRACE("ArtistCell held")
}

- (void)onSelected {
    UI_TRACE("ArtistCell selected")
    if ([self.parentTVC isKindOfClass:[SpotifySearchTVC class]]) {
        [self.parentTVC performSegueWithIdentifier:ARTIST_SELECT_SEGUE sender:self];
    }
}

@end
