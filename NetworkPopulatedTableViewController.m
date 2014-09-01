//
//  NetworkPopulatedTableViewController.m
//  StreamingApp
//
//  Created by Tyler Much on 9/1/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "NetworkPopulatedTableViewController.h"
#import "JFUrlUtil.h"

NSString * const baseURL = @"http://www.tylermuch.com:5000/";

@interface NetworkPopulatedTableViewController ()

@end

@implementation NetworkPopulatedTableViewController

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
    NSMutableString *urlString = [baseURL mutableCopy];
    [urlString appendString:@"list"];
    
    if (album != nil && artist == nil) {
        return; //we can't handle this. An artist must be specified with the album.
    }
    
    if (artist != nil) {
        [urlString appendString:@"/"];
        [urlString appendString:artist];
    }
    
    if (album != nil) {
        [urlString appendString:@"/"];
        [urlString appendString:album];
    }
    
    NSLog(@"Request URL: %@", urlString);
    NSString *encodedURL = [JFUrlUtil encodeUrl:urlString];
    
    NSURL *url = [NSURL URLWithString:encodedURL];
    
    dispatch_queue_t jsonFetchQueue = dispatch_queue_create("json fetcher", NULL);
    dispatch_async(jsonFetchQueue, ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSError *error = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (error != nil) {
            NSLog(@"Error parsing JSON.");
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.tableItems = [jsonArray mutableCopy];
                [self.tableView reloadData];
            });
        }
    });
    
}

@end
