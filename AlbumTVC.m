//
//  AlbumTVC.m
//  StreamingApp
//
//  Created by Tyler Much on 9/24/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "AlbumTVC.h"

@implementation AlbumTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [StreamingAppUtil assignRefreshControlToTVC:self actionSelector:@selector(populateTable)];
    
    [self populateTable];
}

- (void)populateTable {
    [StreamingAppUtil populateTVC:self artist:self.givenArtist album:nil];
}

- (void)stopRefresh {
    if ([self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"AlbumCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [self.tableItems objectAtIndex:indexPath.row];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Songs"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setAlbumAndArtistFromDictionary:)]) {
                    NSString *selectedAlbum = self.tableItems[indexPath.row];
                    NSDictionary *dict = @{@"artist": self.givenArtist, @"album": selectedAlbum};
                    [segue.destinationViewController performSelector:@selector(setAlbumAndArtistFromDictionary:) withObject:dict];
                }
            }
        }
    }
}

- (void)setArtist:(NSString *)artist {
    _givenArtist = artist;
    self.title = artist;
    [self populateTable];
}



@end
