//
//  ArtistTVC.m
//  StreamingApp
//
//  Created by Tyler Much on 9/23/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "ArtistTVC.h"

@implementation ArtistTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [StreamingAppUtil assignRefreshControlToTVC:self actionSelector:@selector(populateTable)];
    [self populateTable];
}

- (void)populateTable {
    [StreamingAppUtil populateTVC:self artist:nil album:nil];
}

- (void)stopRefresh {
    if ([self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"ArtistCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [self.tableItems objectAtIndex:indexPath.row];
    return cell;
}

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
