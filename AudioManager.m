//
//  AudioManager.m
//  StreamingApp
//
//  Created by Tyler  Much on 9/11/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "AudioManager.h"

@interface AudioManager ()
@property (nonatomic, strong) NSMutableArray *previouslyPlayed;
@end

@implementation AudioManager

+ (id)sharedInstance {
    static dispatch_once_t predicate = 0;
    __strong static AudioManager *_shared;
    dispatch_once(&predicate, ^{
        _shared = [[self alloc] init];
    });
    return _shared;
}

- (id)init {
    if (self = [super init]) {
        self.firstQueue = [[NSMutableArray alloc] init];
        self.secondQueue = [[NSMutableArray alloc] init];
        self.playlists = [[NSMutableArray alloc] init];
        self.previouslyPlayed = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addSongWithURIToQueue:(NSURL *)uri {
    // Inserts uri at the end of the array
    [self.firstQueue addObject:uri];
}

- (void)play {
    if (self.nowPlaying == nil) {
        //dequeue a song and play it
        [self next];
    } else {
        [self.nowPlaying play];
    }
}

- (void)pause {
    if (self.nowPlaying == nil) {
        return;
    }
    
    [self.nowPlaying pause];
}

- (void)next {
    NSURL *uri;
    if ([self.firstQueue count] > 0) {
        uri = [self.firstQueue objectAtIndex:0];
        [self.firstQueue removeObjectAtIndex:0];
    } else if ([self.secondQueue count] > 0) {
        uri = [self.secondQueue objectAtIndex:0];
        [self.secondQueue removeObjectAtIndex:0];
    } else {
        // There are no songs in the queue. Keep the current TrackPlayer the same
        // instead of replacing it with nil.
        self.nowPlaying.initialized = NO;
        return;
    }
    
    NSURL *previousURI = self.nowPlaying.track.uri;
    if (previousURI != nil) {
        [self.previouslyPlayed insertObject:previousURI atIndex:0];
    }
    
    // Ensure that there are only ever 10 songs in here. We probably don't care
    // to keep a history much longer than that.
    if ([self.previouslyPlayed count] > 10) {
        [self.previouslyPlayed removeLastObject];
    }
    
    TrackPlayer *newPlayer = [[TrackPlayer alloc] initWithURI:uri];
    [self waitForTrackPlayerInitAndPlay:newPlayer];
    
}

- (void)previous {
    NSURL *uri = nil;
    if ([self.previouslyPlayed count] > 0) {
        uri = [self.previouslyPlayed objectAtIndex:0];
        [self.previouslyPlayed removeObjectAtIndex:0];
    } else return; // No previously played songs. Do nothing.
    
    TrackPlayer *newPlayer = [[TrackPlayer alloc] initWithURI:uri];
    [self waitForTrackPlayerInitAndPlay:newPlayer];
}

- (void)waitForTrackPlayerInitAndPlay:(TrackPlayer *)player {
    dispatch_queue_t waitForInit = dispatch_queue_create("waitforinit", NULL);
    dispatch_async(waitForInit, ^{
        while (!player.initialized);
        self.nowPlaying = player;
        [self.nowPlaying play];
    });
}



@end