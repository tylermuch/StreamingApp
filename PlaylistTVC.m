//
//  PlaylistTVC.m
//  StreamingApp
//
//  Created by Tyler Much on 9/24/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "PlaylistTVC.h"

@implementation PlaylistTVC

- (void)viewWillAppear:(BOOL)animated {
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addButtonPressed:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableItems = [[AudioManager sharedInstance] playlists];
}

- (void)alertTextFieldDidChange:(NSNotification *)notification {
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UITextField *playlistName = alertController.textFields.firstObject;
        UIAlertAction *ok = alertController.actions.lastObject;
        ok.enabled = playlistName.text.length > 0;
    }
}

- (void)addButtonPressed:(UIBarButtonItem *)button {
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *reuse = @"PlaylistCell";
    
    PlaylistCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
    
    if (cell == nil) {
        cell = [[PlaylistCell alloc] initWithParentTVC:self reuseIdentifier:reuse];
    }
    cell.parentTVC = self;
    cell.textLabel.text = [[self.tableItems objectAtIndex:indexPath.row] name];
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
