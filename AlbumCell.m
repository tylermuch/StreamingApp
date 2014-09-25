//
//  AlbumCell.m
//  StreamingApp
//
//  Created by Tyler Much on 9/24/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "AlbumCell.h"

@implementation AlbumCell

- (void)onSelected {
    
}

- (void)onHeld {
    if (![self.parentTVC isKindOfClass:[AlbumTVC class]]) return;
    
    AlbumTVC *tvc = (AlbumTVC *)self.parentTVC;
    
    UIAlertAction *playAlbumAction = [UIAlertAction actionWithTitle:@"Play Album" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Play Album.");
        [[AudioManager sharedInstance] playAlbum:self.textLabel.text artist:tvc.givenArtist];
    }];
    
    UIAlertAction *addToQueueAction = [UIAlertAction actionWithTitle:@"Add To Queue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Add to queue.");
        [[AudioManager sharedInstance] queueAlbum:self.textLabel.text artist:tvc.givenArtist];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.textLabel.text message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:playAlbumAction];
    [alertController addAction:addToQueueAction];
    [alertController addAction:cancelAction];
    [tvc.parentViewController presentViewController:alertController animated:YES completion:nil];
}

@end
