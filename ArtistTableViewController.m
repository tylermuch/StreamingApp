//
//  ArtistTableViewController.m
//  StreamingApp
//
//  Created by Tyler Much on 9/1/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "ArtistTableViewController.h"


@interface ArtistTableViewController ()

@end

@implementation ArtistTableViewController

- (void)refreshTable {
    [self populateArtistTableFromNetwork];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Album"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setArtist:)]) {
                    NSString *artist = self.tableItems[indexPath.row];
                    [segue.destinationViewController performSelector:@selector(setArtist:) withObject:artist];
                }
            }
        }
    }
}
@end
