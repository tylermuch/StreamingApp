//
//  SongTableViewController.m
//  StreamingApp
//
//  Created by Tyler Much on 9/1/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "SongTableViewController.h"

@interface SongTableViewController ()

@end

@implementation SongTableViewController
{
    NSString *givenAlbum;
    NSString *givenArtist;
}


- (void)refreshTable {
    [self populateSongsTableFromNetworkForAlbum:givenAlbum fromArtist:givenArtist];
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

- (void)setAlbumAndArtistFromDictionary:(NSDictionary *)dict {
    givenArtist = [dict objectForKey:@"artist"];
    givenAlbum = [dict objectForKey:@"album"];
    self.title = givenAlbum;
    [self refreshTable];
}

@end
