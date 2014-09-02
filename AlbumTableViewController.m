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

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.tableItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"CellyCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [self.tableItems objectAtIndex:indexPath.row];
    return cell;
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
