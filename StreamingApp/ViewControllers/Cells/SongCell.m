//
//  SongCell.m
//  StreamingApp
//
//  Created by Tyler Much on 9/24/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "SongCell.h"
#import "SpotifyAlbumTVC.h"
#import "SpotifyArtistTVC.h"
#import "SpotifySearchTVC.h"
#include "debug.h"

@implementation SongCell

- (void)alertTextFieldDidChange:(NSNotification *)notification {
    UIAlertController *alertController = nil;
    
    if ([self.parentTVC isKindOfClass:[SpotifySearchTVC class]]) {
        alertController = (UIAlertController *)self.parentTVC.parentViewController.parentViewController.presentedViewController;
    } else alertController = (UIAlertController *)self.parentTVC.presentedViewController;
    
    if (alertController) {
        UITextField *playlistName = alertController.textFields.firstObject;
        UIAlertAction *ok = alertController.actions.lastObject;
        ok.enabled = playlistName.text.length > 0;
    }
}

- (void)onHeld {
    UI_TRACE("SongCell held");
    NSURL *musicURI = nil;
    if ([self.parentTVC isKindOfClass:[SongTVC class]]) {
        NSLog(@"SongTVC");
        SongTVC *tvc = (SongTVC *)self.parentTVC;
        musicURI = [StreamingAppUtil musicUrlForArtist:tvc.givenArtist album:tvc.givenAlbum song:self.textLabel.text];
    } else if([self.parentTVC isKindOfClass:[SpotifyAlbumTVC class]]) {
        NSLog(@"SpotifyAlbumTVC");
        SpotifyAlbumTVC *tvc = (SpotifyAlbumTVC *)self.parentTVC;
        musicURI = ((SPTPartialTrack *)([tvc.tableItems objectAtIndex:[tvc.tableView indexPathForCell:self].row])).uri;
    } else if ([self.parentTVC isKindOfClass:[SpotifyArtistTVC class]]) {
        NSLog(@"SpotifyArtistTVC");
        SpotifyArtistTVC *tvc = (SpotifyArtistTVC *)self.parentTVC;
        musicURI = ((SPTPartialTrack *)([tvc.songs objectAtIndex:[tvc.tableView indexPathForCell:self].row])).uri;
    } else if ([self.parentTVC isKindOfClass:[SpotifySearchTVC class]]) {
        NSLog(@"SpotifySearchTVC");
        SpotifySearchTVC *tvc = (SpotifySearchTVC *)self.parentTVC;
        musicURI = ((SPTPartialTrack *)([tvc.searchResultsSongs objectAtIndex:[tvc.tableView indexPathForCell:self].row])).uri;
    } else return;
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
        if ([self.parentTVC isKindOfClass:[SpotifySearchTVC class]])
            [self.parentTVC presentViewController:playlistCreateController animated:YES completion:nil];
        else [self.parentTVC.parentViewController presentViewController:playlistCreateController animated:YES completion:nil];
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
        if ([self.parentTVC isKindOfClass:[SpotifySearchTVC class]])
            [self.parentTVC presentViewController:playlistController animated:YES completion:nil];
        else [self.parentTVC.parentViewController presentViewController:playlistController animated:YES completion:nil];
    }];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.textLabel.text message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:playSongAction];
    [alertController addAction:addToQueueAction];
    [alertController addAction:addToPlaylistAction];
    [alertController addAction:cancelAction];
    
    if ([self.parentTVC isKindOfClass:[SpotifySearchTVC class]])
        [self.parentTVC presentViewController:alertController animated:YES completion:nil];
    else [self.parentTVC.parentViewController presentViewController:alertController animated:YES completion:nil];

}

- (void)onSelected {
    UI_TRACE("SongCell selected: %@", self.textLabel.text)
    
    NSURL *musicURI = nil;
    if ([self.parentTVC isKindOfClass:[SongTVC class]]) {
        SongTVC *tvc = (SongTVC *)self.parentTVC;
        musicURI = [StreamingAppUtil musicUrlForArtist:tvc.givenArtist album:tvc.givenAlbum song:self.textLabel.text];
    } else if([self.parentTVC isKindOfClass:[SpotifyAlbumTVC class]]) {
        SpotifyAlbumTVC *tvc = (SpotifyAlbumTVC *)self.parentTVC;
        musicURI = ((SPTPartialTrack *)([tvc.tableItems objectAtIndex:[tvc.tableView indexPathForCell:self].row])).uri;
    } else if ([self.parentTVC isKindOfClass:[SpotifyArtistTVC class]]) {
        SpotifyArtistTVC *tvc = (SpotifyArtistTVC *)self.parentTVC;
        musicURI = ((SPTPartialTrack *)([tvc.songs objectAtIndex:[tvc.tableView indexPathForCell:self].row])).uri;
    } else if ([self.parentTVC isKindOfClass:[SpotifySearchTVC class]]) {
        SpotifySearchTVC *tvc = (SpotifySearchTVC *)self.parentTVC;
        musicURI = ((SPTPartialTrack *)([tvc.searchResultsSongs objectAtIndex:[tvc.tableView indexPathForCell:self].row])).uri;
    } else return;
    
    [[AudioManager sharedInstance] playSongWithURI:musicURI];
}

@end
