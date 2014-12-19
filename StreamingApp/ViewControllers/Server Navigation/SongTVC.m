//
//  SongTVC.m
//  StreamingApp
//
//  Created by Tyler Much on 9/24/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "SongTVC.h"

@implementation SongTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [StreamingAppUtil assignRefreshControlToTVC:self actionSelector:@selector(populateTable)];
    
    [self populateTable];
}

- (void)populateTable {
    [StreamingAppUtil populateTVC:self artist:self.givenArtist album:self.givenAlbum];
}

- (void)stopRefresh {
    if ([self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *reuse = @"SongCell";
    
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
    
    if (cell == nil) {
        cell = [[SongCell alloc] initWithParentTVC:self reuseIdentifier:reuse];
    }
    cell.parentTVC = self;
    cell.textLabel.text = [self.tableItems objectAtIndex:indexPath.row];
    return cell;
}

- (void)setAlbumAndArtistFromDictionary:(NSDictionary *)dict {
    _givenArtist = [dict objectForKey:@"artist"];
    _givenAlbum = [dict objectForKey:@"album"];
    self.title = _givenAlbum;
    [self populateTable];
}

@end
