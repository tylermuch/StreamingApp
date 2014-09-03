//
//  SongTableViewController.m
//  StreamingApp
//
//  Created by Tyler Much on 9/1/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "SongTableViewController.h"

@interface SongTableViewController () <UIActionSheetDelegate>

@end

@implementation SongTableViewController
{
    NSString *givenAlbum;
    NSString *givenArtist;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePressHoldFrom:)];
    [self.tableView addGestureRecognizer:gesture];
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
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // TODO: Implement for each button
}

- (void)tableView:(UITableView *)tableView didHoldRowAtIndexPath:(NSIndexPath *)indexPath {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text  delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Play Song", @"Add to Queue", @"Add to Playlist", nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

@end
