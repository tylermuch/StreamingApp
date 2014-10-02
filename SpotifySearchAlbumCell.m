//
//  SpotifySearchAlbumCell.m
//  StreamingApp
//
//  Created by Tyler Much on 9/29/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "SpotifySearchAlbumCell.h"
#import "SpotifySearchTVC.h"
#import "AudioManager.h"

@implementation SpotifySearchAlbumCell

- (void)onHeld {
    NSLog(@"Album cell held.");
    if (![self.parentTVC isKindOfClass:[SpotifySearchTVC class]]) return;
    
    SpotifySearchTVC *tvc = (SpotifySearchTVC *)self.parentTVC;
    NSURL *uri = ((SPTPartialAlbum *)(tvc.searchResultsAlbums[[tvc.tableView indexPathForCell:self].row])).uri;
    
    UIAlertAction *playAlbumAction = [UIAlertAction actionWithTitle:@"Play Album" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Play Album.");
        [[AudioManager sharedInstance] playSpotifyAlbum:uri];
    }];
    
    UIAlertAction *addToQueueAction = [UIAlertAction actionWithTitle:@"Add To Queue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Add to queue.");
        [[AudioManager sharedInstance] queueSpotifyAlbum:uri];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.textLabel.text message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:playAlbumAction];
    [alertController addAction:addToQueueAction];
    [alertController addAction:cancelAction];
    [tvc.parentViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)onSelected {
    NSLog(@"Album cell selected.");
}

@end
