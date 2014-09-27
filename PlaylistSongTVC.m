//
//  PlaylistSongTVC.m
//  StreamingApp
//
//  Created by Tyler Much on 9/24/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "PlaylistSongTVC.h"

@implementation PlaylistSongTVC

- (void)setPlaylist:(TrackPlaylist *)playlist {
    _givenPlaylist = playlist;
    self.title = playlist.name;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableItems = self.givenPlaylist.tracks;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *reuse = @"PlaylistSongCell";
    
    PlaylistSongCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
    
    if (cell == nil) {
        cell = [[PlaylistSongCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse];
    }
    
    cell.parentTVC = self;
    cell.textLabel.text = [[self.givenPlaylist.tracks objectAtIndex:indexPath.row] name];
    return cell;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed:)];
    self.navigationItem.rightBarButtonItem = editButton;
}

- (void)editButtonPressed:(UIBarButtonItem *)button {
    [self.tableView setEditing:![self.tableView isEditing] animated:YES];
    if ([self.tableView isEditing]) {
        [button setTitle:@"Done"];
    } else [button setTitle:@"Edit"];
}

- (void)alertTextFieldDidChange:(NSNotification *)notification {
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UITextField *playlistName = alertController.textFields.firstObject;
        UIAlertAction *ok = alertController.actions.lastObject;
        ok.enabled = playlistName.text.length > 0;
    }
}






- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [self.givenPlaylist.tracks exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Deleting row");
    [self.givenPlaylist.tracks removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


@end
