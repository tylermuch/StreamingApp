//
//  PlaylistSongCell.m
//  StreamingApp
//
//  Created by Tyler Much on 9/24/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "PlaylistSongCell.h"
#include "debug.h"

@implementation PlaylistSongCell

- (void)alertTextFieldDidChange:(NSNotification *)notification {
    UIAlertController *alertController = (UIAlertController *)self.parentTVC.presentedViewController;
    if (alertController) {
        UITextField *playlistName = alertController.textFields.firstObject;
        UIAlertAction *ok = alertController.actions.lastObject;
        ok.enabled = playlistName.text.length > 0;
    }
}


- (void)onSelected {
    UI_TRACE("PlaylistSongCell selected.")
    if ([self.parentTVC isKindOfClass:[PlaylistSongTVC class]]) {
        PlaylistSongTVC *tvc = (PlaylistSongTVC *)self.parentTVC;
        [[AudioManager sharedInstance] playSongWithURI:((Track *)([tvc.givenPlaylist tracks][[tvc.tableView indexPathForCell:self].row])).uri];
    }
}

- (void)onHeld {
    UI_TRACE("PlaylistSongCell held.")
    if (![self.parentTVC isKindOfClass:[PlaylistSongTVC class]]) return;
    PlaylistSongTVC *tvc = (PlaylistSongTVC *)self.parentTVC;
    NSURL *musicURI = [[tvc.givenPlaylist.tracks objectAtIndex:[tvc.tableView indexPathForCell:self].row] uri];
    
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
        [self.parentTVC.parentViewController presentViewController:playlistCreateController animated:YES completion:nil];
    }];
    [playlistController addAction:createPlaylistAction];
    for (TrackPlaylist *playlist in [[AudioManager sharedInstance] playlists]) {
        if ([playlist isEqual:tvc.givenPlaylist]) {
            continue;
        }
        UIAlertAction *playlistAA = [UIAlertAction actionWithTitle:playlist.name style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"Adding to playlist: %@.", action.title);
            [playlist addTrackWithURI:musicURI];
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
        //[self.parentViewController presentViewController:playlistController animated:YES completion:nil];
        [self.parentTVC.parentViewController presentViewController:playlistController animated:YES completion:^{
            NSLog(@"complete");
        }];
    }];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[tvc.tableView cellForRowAtIndexPath:[tvc.tableView indexPathForCell:self]].textLabel.text message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:playSongAction];
    [alertController addAction:addToQueueAction];
    [alertController addAction:addToPlaylistAction];
    [alertController addAction:cancelAction];
    [self.parentTVC.parentViewController presentViewController:alertController animated:YES completion:nil];
}

@end
