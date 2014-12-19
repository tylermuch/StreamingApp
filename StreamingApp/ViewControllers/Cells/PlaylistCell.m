//
//  PlaylistCell.m
//  StreamingApp
//
//  Created by Tyler Much on 9/24/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "PlaylistCell.h"
#include "debug.h"

@implementation PlaylistCell

- (void)alertTextFieldDidChange:(NSNotification *)notification {
    UIAlertController *alertController = (UIAlertController *)self.parentTVC.presentedViewController;
    if (alertController) {
        UITextField *playlistName = alertController.textFields.firstObject;
        UIAlertAction *ok = alertController.actions.lastObject;
        ok.enabled = playlistName.text.length > 0;
    }
}

- (void)onHeld {
    UI_TRACE("PlaylistCell held.")
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    /* Change Name AlertAction */
    UIAlertController *changeNameController = [UIAlertController alertControllerWithTitle:@"Change Playlist Name" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [changeNameController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = [[[[AudioManager sharedInstance] playlists] objectAtIndex:[self.parentTVC.tableView indexPathForCell:self].row] name];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
    }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *newName = changeNameController.textFields.firstObject;
                                   [[[[AudioManager sharedInstance] playlists] objectAtIndex:[self.parentTVC.tableView indexPathForCell:self].row] setName:newName.text];
                                   [self.parentTVC.tableView reloadData];
                                   [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
                               }];
    okAction.enabled = YES;
    [changeNameController addAction:cancelAction];
    [changeNameController addAction:okAction];
    
    /* Confirm Delete AlertAction */
    UIAlertController *confirmDeleteController = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okDeleteAction = [UIAlertAction
                                     actionWithTitle:@"Yes"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         [[[AudioManager sharedInstance] playlists] removeObjectAtIndex:[self.parentTVC.tableView indexPathForCell:self].row];
                                         [self.parentTVC.tableView deleteRowsAtIndexPaths:@[[self.parentTVC.tableView indexPathForCell:self]] withRowAnimation:UITableViewRowAnimationFade];
                                     }];
    [confirmDeleteController addAction:cancelAction];
    [confirmDeleteController addAction:okDeleteAction];
    
    
    UIAlertAction *addToQueueAction = [UIAlertAction actionWithTitle:@"Add Playlist To Queue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Adding Playlist To Queue");
        [[AudioManager sharedInstance] queuePlaylistAtIndexPath:[self.parentTVC.tableView indexPathForCell:self] shuffled:NO];
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete Playlist" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        NSLog(@"Deleting playlist (asking for confirmation first)");
        [self.parentTVC.parentViewController presentViewController:confirmDeleteController animated:YES completion:nil];
    }];
    UIAlertAction *changeNameAction = [UIAlertAction actionWithTitle:@"Change Name" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Changing name");
        [self.parentTVC.parentViewController presentViewController:changeNameController animated:YES completion:nil];
    }];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[self.parentTVC.tableView cellForRowAtIndexPath:[self.parentTVC.tableView indexPathForCell:self]].textLabel.text message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:addToQueueAction];
    [alertController addAction:changeNameAction];
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    [self.parentTVC.parentViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)onSelected {
    UI_TRACE("PlaylistCell selected")
}

@end
