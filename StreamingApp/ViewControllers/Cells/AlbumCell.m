//
//  AlbumCell.m
//  StreamingApp
//
//  Created by Tyler Much on 9/24/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "AlbumCell.h"
#import "SpotifyArtistTVC.h"
#import "SpotifySearchTVC.h"
#include "debug.h"

extern NSString * const ALBUM_SELECT_SEGUE;

@implementation AlbumCell

- (void)onSelected {
    UI_TRACE("AlbumCell selected")
    if ([self.parentTVC isKindOfClass:[SpotifySearchTVC class]]) {
        [self.parentTVC performSegueWithIdentifier:ALBUM_SELECT_SEGUE sender:self];
    }
}

- (void)onHeld {
    UI_TRACE("AlbumCell held")
    NSURL *uri = nil;
    ParentTableViewController *tvc = nil;

    if ([self.parentTVC isKindOfClass:[AlbumTVC class]]) {
        tvc = (AlbumTVC *)self.parentTVC;
    } else if ([self.parentTVC isKindOfClass:[SpotifyArtistTVC class]]) {
        SpotifyArtistTVC *stvc = (SpotifyArtistTVC *)self.parentTVC;
        uri = ((SPTPartialAlbum *)([stvc.albums objectAtIndex:[tvc.tableView indexPathForCell:self].row])).uri;
        tvc = (ParentTableViewController *)self.parentTVC;
    } else if ([self.parentTVC isKindOfClass:[SpotifySearchTVC class]]) {
        SpotifySearchTVC *stvc = (SpotifySearchTVC *)self.parentTVC;
        uri = ((SPTPartialAlbum *)([stvc.searchResultsAlbums objectAtIndex:[stvc.tableView indexPathForCell:self].row])).uri;
        tvc = (ParentTableViewController *)self.parentTVC;
    } else return;
    
    UIAlertAction *playAlbumAction = [UIAlertAction actionWithTitle:@"Play Album" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Play Album.");
        if (uri) {
            [[AudioManager sharedInstance] playSpotifyAlbum:uri];
            return;
        } else {
            [[AudioManager sharedInstance] playAlbum:self.textLabel.text artist:((AlbumTVC *)tvc).givenArtist];
            return;
        }
    }];
    
    UIAlertAction *addToQueueAction = [UIAlertAction actionWithTitle:@"Add To Queue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Add to queue.");
        if (uri) {
            [[AudioManager sharedInstance] queueSpotifyAlbum:uri];
            return;
        } else {
            [[AudioManager sharedInstance] queueAlbum:self.textLabel.text artist:((AlbumTVC *)tvc).givenArtist];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.textLabel.text message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:playAlbumAction];
    [alertController addAction:addToQueueAction];
    [alertController addAction:cancelAction];
    [tvc.parentViewController presentViewController:alertController animated:YES completion:nil];
}

@end
