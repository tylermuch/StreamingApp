//
//  SpotifySearchSongCell.m
//  StreamingApp
//
//  Created by Tyler Much on 9/28/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "SpotifySearchSongCell.h"
#import "AudioManager.h"
#import "SpotifySearchTVC.h"

@implementation SpotifySearchSongCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    return [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

- (void)alertTextFieldDidChange:(NSNotification *)notification {
    id alertController = self.parentTVC.parentViewController.parentViewController.presentedViewController;
    if (alertController != nil && [alertController isKindOfClass:[UIAlertController class]]) {
        UIAlertController *ac = (UIAlertController *)alertController;
        UITextField *playlistName = ac.textFields.firstObject;
        UIAlertAction *ok = ac.actions.lastObject;
        ok.enabled = playlistName.text.length > 0;
    }
}

- (void)onHeld {
    if (![self.parentTVC isKindOfClass:[SpotifySearchTVC class]]) {
        return;
    }
    SpotifySearchTVC *tvc = (SpotifySearchTVC *)self.parentTVC;
    NSUInteger index = [[(UITableViewController *)([[tvc searchController] searchResultsController]) tableView] indexPathForCell:self].row;
    SPTTrack *track = (SPTTrack *)[[tvc searchResultsSongs] objectAtIndex:index];
    NSURL *musicURI = track.uri;
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    /* Playlist Create AlertAction */
    UIAlertController *playlistCreateController = [UIAlertController alertControllerWithTitle:@"Create Playlist" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [playlistCreateController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Playlist Name";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
    }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *playlistName = playlistCreateController.textFields.firstObject;
                                   [[AudioManager sharedInstance] createPlaylistWithName:playlistName.text andTrackURI:musicURI];
                                   [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
                               }];
    okAction.enabled = NO;
    [playlistCreateController addAction:cancelAction];
    [playlistCreateController addAction:okAction];
    /* *************************** */
    
    /* Playlist ActionSheet */
    UIAlertController *playlistController = [UIAlertController alertControllerWithTitle:@"Add To Playlist" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *createPlaylistAction = [UIAlertAction actionWithTitle:@"Create New Playlist" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.parentTVC presentViewController:playlistCreateController animated:YES completion:nil];
    }];
    [playlistController addAction:createPlaylistAction];
    for (TrackPlaylist *playlist in [[AudioManager sharedInstance] playlists]) {
        UIAlertAction *playlistAA = [UIAlertAction actionWithTitle:playlist.name style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"%@", playlist.name);
            NSLog(@"Adding to playlist: %@.", action.title);
            [playlist addTrackWithURI:musicURI];
            NSLog(@"%@", playlist.name);
        }];
        [playlistController addAction:playlistAA];
    }
    [playlistController addAction:cancelAction];
    /* ******************** */
    
    
    UIAlertAction *playSongAction = [UIAlertAction actionWithTitle:@"Play Song" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[AudioManager sharedInstance] playSongWithURI:musicURI];
    }];
    UIAlertAction *addToQueueAction = [UIAlertAction actionWithTitle:@"Add To Queue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Queueing song.");
        [[AudioManager sharedInstance] addSongWithURIToQueue:musicURI];
    }];
    UIAlertAction *addToPlaylistAction = [UIAlertAction actionWithTitle:@"Add To Playlist" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Add to playlist");
        [self.parentTVC presentViewController:playlistController animated:YES completion:^{
            NSLog(@"complete");
        }];
    }];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.textLabel.text message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:playSongAction];
    [alertController addAction:addToQueueAction];
    [alertController addAction:addToPlaylistAction];
    [alertController addAction:cancelAction];
    [self.parentTVC presentViewController:alertController animated:YES completion:nil];
    
}

- (void)onSelected {
    SpotifySearchTVC *tvc = (SpotifySearchTVC *)self.parentTVC;
    NSUInteger index = [[(UITableViewController *)([[tvc searchController] searchResultsController]) tableView] indexPathForCell:self].row;
    SPTPartialTrack *track = (SPTPartialTrack *)[[tvc searchResultsSongs] objectAtIndex:index];
    NSURL *uri = track.uri;
    [[AudioManager sharedInstance] playSongWithURI:uri];
}

@end
