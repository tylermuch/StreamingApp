//
//  TrackPlayer.m
//  StreamingApp
//
//  Created by Tyler  Much on 9/11/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "TrackPlayer.h"

@implementation TrackPlayer

- (id)initWithURI:(NSURL *)uri {
    if (self = [super init]) {
        self.initialized = NO;
        self.player = nil;
        self.track = [[Track alloc] init];
        
        self.track.name = [StreamingAppUtil songFromMusicURL:uri];
        self.track.uri = uri;
        self.track.artist = [StreamingAppUtil artistFromMusicURL:uri];
        self.track.album = [StreamingAppUtil albumFromMusicURL:uri];
        self.player = [AVPlayer playerWithURL:uri];
        self.initialized = YES;
        return self;
    }
    return nil;
}

- (void)play {
    NSLog(@"Play");
    if (self.player == nil) {
        return;
    }
    
    if ([self.player isKindOfClass:[AVPlayer class]]) {
        NSLog(@"AVPlayer");
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
