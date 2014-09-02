//
//  SongTableViewController.m
//  StreamingApp
//
//  Created by Tyler Much on 9/1/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "SongTableViewController.h"
#include "SwipeableSongCell.h"

@interface SongTableViewController () <SwipeableCellDelegate>
@property (nonatomic, strong) NSMutableSet *cellsCurrentlyEditing;
@end

@implementation SongTableViewController
{
    NSString *givenAlbum;
    NSString *givenArtist;
    int rowSelected;
}

- (void)cellDidOpen:(UITableViewCell *)cell {
    NSIndexPath *currentEditingIndexPath = [self.tableView indexPathForCell:cell];
    [self.cellsCurrentlyEditing addObject:currentEditingIndexPath];
}

- (void)cellDidClose:(UITableViewCell *)cell {
    [self.cellsCurrentlyEditing removeObject:[self.tableView indexPathForCell:cell]];
}

- (void)viewDidLoad {
    rowSelected = -1;
    self.cellsCurrentlyEditing = [NSMutableSet new];
}

- (void)refreshTable {
    [self populateSongsTableFromNetworkForAlbum:givenAlbum fromArtist:givenArtist];
}

- (void)setAlbumAndArtistFromDictionary:(NSDictionary *)dict {
    givenArtist = [dict objectForKey:@"artist"];
    givenAlbum = [dict objectForKey:@"album"];
    self.title = givenAlbum;
    [self refreshTable];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView beginUpdates];
    [tableView endUpdates];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (rowSelected >= 0) {
        if (indexPath.row == rowSelected) {
            return 88;
        }
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SwipeableSongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellyCell" forIndexPath:indexPath];
    
    NSString *item = [self.tableItems objectAtIndex:indexPath.row];
    cell.itemText = item;
    
    cell.delegate = self;
    
    if ([self.cellsCurrentlyEditing containsObject:indexPath]) {
        [cell openCell];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"Removing object at index %ld!", (long)indexPath.row);
    } else {
        NSLog(@"Unhandled editing style! %ld", editingStyle);
    }
}

#pragma mark - SwipeableCellDelegate
- (void)buttonOneActionForItemText:(NSString *)itemText {
    NSLog(@"In the delegate, clicked button one for %@", itemText);
}

- (void)buttonTwoActionForItemText:(NSString *)itemText {
    NSLog(@"In the delegate, clicked button two for %@", itemText);
}

@end
