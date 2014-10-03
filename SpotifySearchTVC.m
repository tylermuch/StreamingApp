//
//  SpotifySearchTVC.m
//  StreamingApp
//
//  Created by Tyler Much on 9/28/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "SpotifySearchTVC.h"
#import <Spotify/Spotify.h>
#import "AudioManager.h"
#import "SpotifySearchSongCell.h"
#import "SpotifySearchArtistCell.h"
#import "SpotifySearchAlbumCell.h"

NSString * const ARTIST_SELECT_SEQUE = @"SPTSelectArtist";
NSString * const ALBUM_SELECT_SEQUE = @"SPTSelectAlbum";

@interface SpotifySearchTVC () <UISearchResultsUpdating>

@end

@implementation SpotifySearchTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _searchResultsArtists = [[NSMutableArray alloc] init];
    _searchResultsAlbums = [[NSMutableArray alloc] init];
    _searchResultsSongs = [[NSMutableArray alloc] init];
    
    ParentTableViewController *searchResultsController = [[ParentTableViewController alloc] initWithStyle:UITableViewStylePlain];
    searchResultsController.tableView.dataSource = self;
    searchResultsController.tableView.delegate = self;
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePressHoldFrom:)];
    [searchResultsController.tableView addGestureRecognizer:gesture];
    [searchResultsController.tableView registerClass:[SpotifySearchSongCell class] forCellReuseIdentifier:@"SpotifyCell"];
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchResultsUpdater = self;
    
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    
    self.tabBarController.tabBar.translucent = NO;
    
    self.definesPresentationContext = YES;
    
}

/*- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //hack to solve problem of cells becoming unresponsive when switching to another ViewController and back
    _searchResultsAlbums = nil;
    _searchResultsArtists = nil;
    _searchResultsSongs = nil;
    
    [((ParentTableViewController *)(self.searchController.searchResultsController)).tableView reloadData];
}*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [((ParentTableViewController *)(self.searchController.searchResultsController)).tableView reloadData];
}

- (void)handlePressHoldFrom:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        UITableView *resultsTableView = [(ParentTableViewController *)(self.searchController.searchResultsController) tableView];
        CGPoint holdLocation = [recognizer locationInView:resultsTableView];
        NSIndexPath *heldIndexPath = [resultsTableView indexPathForRowAtPoint:holdLocation];
        [self tableView:resultsTableView didHoldRowAtIndexPath:heldIndexPath];

    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = 0;
    if ([self.searchResultsSongs count] > 0) {
        count++;
    }
    if ([self.searchResultsAlbums count] > 0) {
        count++;
    }
    if ([self.searchResultsArtists count] > 0) {
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
            return @"Artists";
        case 2:
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
            return [[self searchResultsSongs] count];
        case 1:
            return [[self searchResultsArtists] count];
        case 2:
            return [[self searchResultsAlbums] count];
        default:
            return 0;
    }
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (searchController.searchBar.text == nil || [searchController.searchBar.text isEqualToString:@""]) {
        return;
    }
    
    /* Search for songs */
    [SPTRequest performSearchWithQuery:searchController.searchBar.text queryType:SPTQueryTypeTrack session:[[AudioManager sharedInstance] spotifySession] callback:^(NSError *error, SPTListPage *results){
        if (error) {
            NSLog(@"Error searching spotify.");
        }
        
        _searchResultsSongs = [results.items count] < 10 ? [results.items mutableCopy] : [[results.items objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 10)]] mutableCopy];
        //[((UITableViewController *)self.searchController.searchResultsController).tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [((UITableViewController *)self.searchController.searchResultsController).tableView reloadData];
    }];
    
    /* Search for artists */
    [SPTRequest performSearchWithQuery:searchController.searchBar.text queryType:SPTQueryTypeArtist session:[[AudioManager sharedInstance] spotifySession] callback:^(NSError *error, SPTListPage *results){
        if (error) {
            NSLog(@"Error searching spotify.");
        }
        
        _searchResultsArtists = [results.items count] < 10 ? [results.items mutableCopy] : [[results.items objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 10)]] mutableCopy];
        //[((UITableViewController *)self.searchController.searchResultsController).tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        [((UITableViewController *)self.searchController.searchResultsController).tableView reloadData];
    }];
    
    /* Search for albums */
    [SPTRequest performSearchWithQuery:searchController.searchBar.text queryType:SPTQueryTypeAlbum session:[[AudioManager sharedInstance] spotifySession] callback:^(NSError *error, SPTListPage *results){
        if (error) {
            NSLog(@"Error searching spotify.");
        }
        
        _searchResultsAlbums = [results.items count] < 10 ? [results.items mutableCopy] : [[results.items objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 10)]] mutableCopy];
        //[((UITableViewController *)self.searchController.searchResultsController).tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
        [((UITableViewController *)self.searchController.searchResultsController).tableView reloadData];
    }];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseSong = @"SpotifyCell";
    NSString *reuseArtist = @"SpotifyArtistCell";
    NSString *reuseAlbum = @"SpotifyAlbumCell";
    NSInteger index = indexPath.row;
    NSInteger section = indexPath.section;
    
    if (section == 0) {
        SpotifySearchSongCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseSong];
            
        if (cell == nil) {
            cell = [[SpotifySearchSongCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseSong];
        }
            
        SPTTrack *t;
        t = [self.searchResultsSongs objectAtIndex:index];
        
        cell.parentTVC = self;
        cell.textLabel.text = t.name;
        cell.detailTextLabel.text = ((SPTPartialArtist *)t.artists[0]).name;
        return cell;
    } else if (section == 1) {
        SpotifySearchArtistCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseArtist];
        
        if (cell == nil) {
            cell = [[SpotifySearchArtistCell alloc] initWithParentTVC:self reuseIdentifier:reuseArtist];
        }
        
        SPTPartialArtist *t;
        t = [self.searchResultsArtists objectAtIndex:index];
        
        cell.parentTVC = self;
        cell.textLabel.text = t.name;
        return cell;
    } else if (section == 2) {
        SpotifySearchAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseAlbum];
        
        /*
            I would love for this cell to have subtitle style and display the artist under the album name but 
                the Spotify iOS SDK doesn't currently have an artist field in SPTPartialAlbum and requesting
                the full SPTAlbum in this method would be silly since it's called so often. It also wouldn't help to 
                request it when the search is being done (and the results lists are being populated) since it's just more
                network activity and it slows down the search quite a bit.
         
         */
        
        if (cell == nil) {
            cell = [[SpotifySearchAlbumCell alloc] initWithParentTVC:self reuseIdentifier:reuseAlbum];
        }
        
        SPTPartialAlbum *t;
        t = [self.searchResultsAlbums objectAtIndex:index];
        
        cell.parentTVC = self;
        cell.textLabel.text = t.name;
        return cell;
    } else return nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:ARTIST_SELECT_SEQUE] && [sender isKindOfClass:[SpotifySearchArtistCell class]]) {
        NSLog(@"Segue to album+song view.");
        NSIndexPath *indexPath = [((ParentTableViewController *)(self.searchController.searchResultsController)).tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.destinationViewController respondsToSelector:@selector(setArtist:)]) {
                [segue.destinationViewController performSelector:@selector(setArtist:) withObject:[self.searchResultsArtists objectAtIndex:indexPath.row]];
            }
        }
        
    } else if ([segue.identifier isEqualToString:ALBUM_SELECT_SEQUE] && [sender isKindOfClass:[SpotifySearchAlbumCell class]]) {
        NSLog(@"Segue to song view.");
        NSIndexPath *indexPath = [((ParentTableViewController *)(self.searchController.searchResultsController)).tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.destinationViewController respondsToSelector:@selector(setAlbum:)]) {
                [segue.destinationViewController performSelector:@selector(setAlbum:) withObject:[self.searchResultsAlbums objectAtIndex:indexPath.row]];
            }
        }
    }
}



@end
