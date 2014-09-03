//
//  NetworkPopulatedTableViewController.m
//  StreamingApp
//
//  Created by Tyler Much on 9/1/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "NetworkPopulatedTableViewController.h"
#import "UIApplication+NetworkIndicator.h"
#import "StreamingAppUtil.h"

@interface NetworkPopulatedTableViewController ()
- (void)refreshTable;
@end

@implementation NetworkPopulatedTableViewController

// To be overriden by subclasses. There is almost certainly a better way to do this but I'm not exactly sure how in Objective-C. This works for now.
- (void)refreshTable {
    [NSException raise:@"Invoked abstract method. refresh must be implemented in subclasses" format:@"Invoked abstract method. refresh must be implemented in subclasses"];
}

- (void)viewDidLoad {
    UIRefreshControl *rc = [[UIRefreshControl alloc] init];
    rc.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
    [rc addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = rc;
    
    [self refreshTable];
}

- (void)stopRefresh {
    if ([self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
    }
}

- (void)populateArtistTableFromNetwork {
    [self populateSongsTableFromNetworkForAlbum:nil fromArtist:nil];
}

- (void)populateAlbumTableFromNetworkForArtist:(NSString *)artist {
    if (!artist) {
        return;
    }
    [self populateSongsTableFromNetworkForAlbum:nil fromArtist:artist];
}

- (void)populateSongsTableFromNetworkForAlbum:(NSString *)album fromArtist:(NSString *)artist {
    NSURL *url = [StreamingAppUtil urlForArtist:artist album:album];
    
    if (url == nil) {
        return;
    }
    
    //Need to set network indicator in the main thread before dispatching to fetch queue
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    
    dispatch_queue_t jsonFetchQueue = dispatch_queue_create("json fetcher", NULL);
    dispatch_async(jsonFetchQueue, ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
        });
        
        NSError *error = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (error != nil) {
            NSLog(@"Error parsing JSON.");
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.tableItems = [jsonArray mutableCopy];
                [self.tableView reloadData];
                if ([self respondsToSelector:@selector(stopRefresh)]) {
                    [self performSelector:@selector(stopRefresh) withObject:nil];
                }
            });
        }
    });
    
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

@end
