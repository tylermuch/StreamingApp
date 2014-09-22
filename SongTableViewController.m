//
//  SongTableViewController.m
//  StreamingApp
//
//  Created by Tyler Much on 9/1/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "SongTableViewController.h"

@implementation SongTableViewController
{
    NSString *givenAlbum;
    NSString *givenArtist;
    UIAlertAction *cancelAction;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePressHoldFrom:)];
    [self.tableView addGestureRecognizer:gesture];
    
    cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
}

- (void)handlePressHoldFrom:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint holdLocation = [recognizer locationInView:self.tableView];
        NSIndexPath *heldIndexPath = [self.tableView indexPathForRowAtPoint:holdLocation];
        [self tableView:self.tableView didHoldRowAtIndexPath:heldIndexPath];
    }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected: %@", [tableView cellForRowAtIndexPath:indexPath].textLabel.text);
    [[AudioManager sharedInstance] playSongWithURI:[StreamingAppUtil musicUrlForArtist:givenArtist album:givenAlbum song:[tableView cellForRowAtIndexPath:indexPath].textLabel.text]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)alertTextFieldDidChange:(NSNotification *)notification {
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UITextField *playlistName = alertController.textFields.firstObject;
        UIAlertAction *ok = alertController.actions.lastObject;
        ok.enabled = playlistName.text.length > 0;
    }
}

- (void)tableView:(UITableView *)tableView didHoldRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSURL *musicURI = [StreamingAppUtil musicUrlForArtist:givenArtist album:givenAlbum song:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
    
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
        [self.parentViewController presentViewController:playlistCreateController animated:YES completion:nil];
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
        //[self.parentViewController presentViewController:playlistController animated:YES completion:nil];
        [self.parentViewController presentViewController:playlistController animated:YES completion:^{
            NSLog(@"complete");
        }];
    }];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:playSongAction];
    [alertController addAction:addToQueueAction];
    [alertController addAction:addToPlaylistAction];
    [alertController addAction:cancelAction];
    [self.parentViewController presentViewController:alertController animated:YES completion:nil];
    /*UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text  delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Play Song", @"Add to Queue", @"Add to Playlist", nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];*/
}

@end
