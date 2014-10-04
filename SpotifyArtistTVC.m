//
//  SpotifyArtistTVC.m
//  StreamingApp
//
//  Created by Tyler  Much on 10/3/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "SpotifyArtistTVC.h"
#import "AudioManager.h"
#import "SongCell.h"
#import "AlbumCell.h"

NSString * const ARTIST_SELECT_ALBUM_SEGUE = @"SPTArtistSelectSongSegue";

@implementation SpotifyArtistTVC

- (void)populateTable {
    [SPTRequest requestItemFromPartialObject:self.givenArtist withSession:[[AudioManager sharedInstance] spotifySession] callback:^(NSError *error, id object){
        if (error) {
            NSLog(@"Error requesting item from partial object: %@", error);
            return;
        }
        
        if ([object isKindOfClass:[SPTArtist class]]) {
            SPTArtist *artist = (SPTArtist *)object;
            [artist requestTopTracksForTerritory:@"US" withSession:[[AudioManager sharedInstance] spotifySession] callback:^(NSError *error, id object) {
                if (error) {
                    NSLog(@"Error requesting top tracks for artist: %@", error);
                    return;
                }
                
                if ([object isKindOfClass:[NSArray class]]) {
                    NSArray *tracks = (NSArray *)object;
                    _songs = [tracks mutableCopy];
                    [self.tableView reloadData];
                }
            }];
            
            [artist requestAlbumsOfType:SPTAlbumTypeAlbum withSession:[[AudioManager sharedInstance] spotifySession] availableInTerritory:@"US" callback:^(NSError *error, id object) {
                if (error) {
                    NSLog(@"Error requesting albums for artist: %@", error);
                    return;
                }
                
                if ([object isKindOfClass:[SPTListPage class]]) {
                    SPTListPage *listpage = (SPTListPage *)object;
                    _albums = [listpage.items mutableCopy];
                    [self.tableView reloadData];
                }
                
            }];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = 0;
    if ([self.songs count] > 0) {
        count++;
    }
    if ([self.albums count] > 0) {
        count++;
    }
    return count;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Songs";
        case 1:
            return @"Albums";
        default:
            return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index {
    return index;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [[self songs] count];
        case 1:
            return [[self albums] count];
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *reuseArtistAlbum = @"SpotifyArtistAlbumCell";
    NSString *reuseArtistSong = @"SpotifyArtistSongCell";
    NSInteger index = indexPath.row;
    NSInteger section = indexPath.section;
    
    if (section == 0) {
        SongCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseArtistSong];
        
        if (cell == nil) {
            cell = [[SongCell alloc] initWithParentTVC:self reuseIdentifier:reuseArtistSong];
        }
        
        cell.parentTVC = self;
        cell.textLabel.text = ((SPTTrack *)([self.songs objectAtIndex:index])).name;
        return cell;
    } else if (section == 1) {
        AlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseArtistAlbum];
        
        if (cell == nil) {
            cell = [[AlbumCell alloc] initWithParentTVC:self reuseIdentifier:reuseArtistAlbum];
        }
        
        cell.parentTVC = self;
        cell.textLabel.text = ((SPTPartialAlbum *)([self.albums objectAtIndex:index])).name;
        return cell;
    } else return nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:ARTIST_SELECT_ALBUM_SEGUE] && [sender isKindOfClass:[AlbumCell class]]) {
        NSLog(@"Segue to album from artist (SPT).");
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.destinationViewController respondsToSelector:@selector(setAlbum:)]) {
                [segue.destinationViewController performSelector:@selector(setAlbum:) withObject:[self.albums objectAtIndex:indexPath.row]];
            }
        }
        
    }
}

- (void)setArtist:(SPTPartialArtist *)artist {
    _givenArtist = artist;
    self.title = artist.name;
    [self populateTable];
}

@end
