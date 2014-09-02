//
//  AlbumTableViewController.m
//  StreamingApp
//
//  Created by Tyler Much on 9/1/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "AlbumTableViewController.h"

@interface AlbumTableViewController ()

@end

@implementation AlbumTableViewController
{
    NSString *givenArtist;
}

- (void)refreshTable {
    [self populateAlbumTableFromNetworkForArtist:givenArtist];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Songs"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setAlbumAndArtistFromDictionary:)]) {
                    NSString *selectedAlbum = self.tableItems[indexPath.row];
                    NSDictionary *dict = @{@"artist": givenArtist, @"album": selectedAlbum};
                    [segue.destinationViewController performSelector:@selector(setAlbumAndArtistFromDictionary:) withObject:dict];
                }
            }
        }
    }
}

- (void)setArtist:(NSString *)artist {
    givenArtist = artist;
    self.title = artist;
    [self refreshTable];
}
@end
