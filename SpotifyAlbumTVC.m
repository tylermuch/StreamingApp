//
//  SpotifyAlbumTVC.m
//  StreamingApp
//
//  Created by Tyler  Much on 10/3/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "SpotifyAlbumTVC.h"
#import "AudioManager.h"
#import "SongCell.h"

@implementation SpotifyAlbumTVC

- (void)populateTable {
    [SPTRequest requestItemFromPartialObject:self.givenAlbum withSession:[[AudioManager sharedInstance] spotifySession] callback:^(NSError *error, id object){
        if (error) {
            NSLog(@"Error requesting item from partial object: %@", error);
            return;
        }
        
        if ([object isKindOfClass:[SPTAlbum class]]) {
            SPTAlbum *album = (SPTAlbum *)object;
            self.tableItems = [album.firstTrackPage.items mutableCopy];
            [self.tableView reloadData];
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *reuse = @"SpotifyAlbumSongCell";
    
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
    
    if (cell == nil) {
        cell = [[SongCell alloc] initWithParentTVC:self reuseIdentifier:reuse];
    }
    
    cell.parentTVC = self;
    cell.textLabel.text = ((SPTPartialTrack *)([self.tableItems objectAtIndex:indexPath.row])).name;
    return cell;
}

- (void)setAlbum:(SPTPartialAlbum *)album {
    _givenAlbum = album;
    self.title = album.name;
    [self populateTable];
}

@end
