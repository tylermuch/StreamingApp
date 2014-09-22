//
//  PlaylistTableViewController.m
//  StreamingApp
//
//  Created by Tyler Much on 9/20/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "PlaylistTableViewController.h"

@implementation PlaylistTableViewController

- (void)viewWillAppear:(BOOL)animated {
    UIBarButtonItem *createButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(createButtonPressed:)];
    self.navigationItem.rightBarButtonItem = createButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePressHoldFrom:)];
    
    [self.tableView addGestureRecognizer:gesture];
}

- (void)createButtonPressed:(UIBarButtonItem *)button {
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertController *createPlaylistController = [UIAlertController alertControllerWithTitle:@"Enter Playlist Name" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [createPlaylistController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Playlist Name";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
    }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *name = createPlaylistController.textFields.firstObject;
                                   [[AudioManager sharedInstance] createPlaylistWithName:name.text andTrackURI:nil];
                                   [self.tableView reloadData];
                                   [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
                               }];
    okAction.enabled = YES;
    [createPlaylistController addAction:cancelAction];
    [createPlaylistController addAction:okAction];
    [self.parentViewController presentViewController:createPlaylistController animated:YES completion:nil];
}

- (void)handlePressHoldFrom:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint holdLocation = [recognizer locationInView:self.tableView];
        NSIndexPath *heldIndexPath = [self.tableView indexPathForRowAtPoint:holdLocation];
        [self tableView:self.tableView didHoldRowAtIndexPath:heldIndexPath];
    }
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
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    /* Change Name AlertAction */
    UIAlertController *changeNameController = [UIAlertController alertControllerWithTitle:@"Change Playlist Name" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [changeNameController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = [[[[AudioManager sharedInstance] playlists] objectAtIndex:indexPath.row] name];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
    }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *newName = changeNameController.textFields.firstObject;
                                   [[[[AudioManager sharedInstance] playlists] objectAtIndex:indexPath.row] setName:newName.text];
                                   [tableView reloadData];
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
                                   [[[AudioManager sharedInstance] playlists] removeObjectAtIndex:indexPath.row];
                                   [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                               }];
    [confirmDeleteController addAction:cancelAction];
    [confirmDeleteController addAction:okDeleteAction];
    
    
    UIAlertAction *addToQueueAction = [UIAlertAction actionWithTitle:@"Add Playlist To Queue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Adding Playlist To Queue");
        [[AudioManager sharedInstance] queuePlaylistAtIndexPath:indexPath shuffled:NO];
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete Playlist" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Deleting playlist (asking for confirmation first)");
        [self.parentViewController presentViewController:confirmDeleteController animated:YES completion:nil];
    }];
    UIAlertAction *changeNameAction = [UIAlertAction actionWithTitle:@"Change Name" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Changing name");
        [self.parentViewController presentViewController:changeNameController animated:YES completion:nil];
    }];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:addToQueueAction];
    [alertController addAction:changeNameAction];
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    [self.parentViewController presentViewController:alertController animated:YES completion:nil];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[AudioManager sharedInstance] playlists] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"PlaylistCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [[[[AudioManager sharedInstance] playlists] objectAtIndex:indexPath.row] name];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"ShowPlaylist"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setPlaylist:)]) {
                    [segue.destinationViewController performSelector:@selector(setPlaylist:) withObject:[[[AudioManager sharedInstance] playlists] objectAtIndex:indexPath.row]];
                }
                
                //[segue.destinationViewController setTitle:[[[[AudioManager sharedInstance] playlists] objectAtIndex:indexPath.row] name]];
            }
        }
    }
}

@end
