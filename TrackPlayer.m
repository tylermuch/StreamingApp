//
//  TrackPlayer.m
//  StreamingApp
//
//  Created by Tyler  Much on 9/11/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "TrackPlayer.h"

@implementation TrackPlayer

- (id)initWithURI:(NSURL *)uri delegate:(id<TrackPlayerDelegate>)delegate{
    if (self = [super init]) {
        self.initialized = NO;
        self.player = nil;
        self.track = [[Track alloc] init];
        
        self.track.name = [StreamingAppUtil songFromMusicURL:uri];
        self.track.uri = uri;
        self.track.artist = [StreamingAppUtil artistFromMusicURL:uri];
        self.track.album = [StreamingAppUtil albumFromMusicURL:uri];
        AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:uri];
        
        // Subscribe to the AVPlayerItem's DidPlayToEndTime notification.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        self.delegate = delegate;
        self.initialized = YES;
        return self;
    }
    return nil;
}

// Called when AVPlayer finishes playing a song
-(void)itemDidFinishPlaying:(NSNotification *) notification {
    NSLog(@"Finished playing %@", notification.object);
    [self.delegate trackDidFinishPlaying];
}

- (void)play {
    NSLog(@"Play");
    if (self.player == nil) {
        return;
    }
    
    if ([self.player isKindOfClass:[AVPlayer class]]) {
        NSLog(@"AVPlayer");
        NSLog(@"Playing: %@", [self.track.uri absoluteString]);
        [((AVPlayer *)self.player) play];
    }
}

- (void)pause {
    if (self.player == nil) {
        return;
    }
    
    if ([self.player isKindOfClass:[AVPlayer class]]) {
        [((AVPlayer *)self.player) pause];
    }
}

@end
