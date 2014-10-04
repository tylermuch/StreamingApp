//
//  AlbumCell.m
//  StreamingApp
//
//  Created by Tyler Much on 9/24/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "AlbumCell.h"
#import "SpotifyArtistTVC.h"

@implementation AlbumCell

- (void)onSelected {
    
}

- (void)onHeld {
    NSURL *uri = nil;
    ParentTableViewController *tvc = nil;

    if ([self.parentTVC isKindOfClass:[AlbumTVC class]]) {
        tvc = (AlbumTVC *)self.parentTVC;
    } else if ([self.parentTVC isKindOfClass:[SpotifyArtistTVC class]]) {
        SpotifyArtistTVC *stvc = (SpotifyArtistTVC *)self.parentTVC;
        uri = ((SPTPartialAlbum *)([stvc.albums objectAtIndex:[tvc.tableView indexPathForCell:self].row])).uri;
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
