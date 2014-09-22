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

#pragma mark Playback Control

- (void)playSongWithURI:(NSURL *)uri {
    TrackPlayer *newPlayer = [[TrackPlayer alloc] initWithURI:uri delegate:self];
    [self waitForTrackPlayerInitAndPlay:newPlayer];
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
    
    TrackPlayer *newPlayer = [[TrackPlayer alloc] initWithURI:uri delegate:self];
    [self waitForTrackPlayerInitAndPlay:newPlayer];
    
}

- (void)previous {
    NSURL *uri = nil;
    if ([self.previouslyPlayed count] > 0) {
        uri = [self.previouslyPlayed objectAtIndex:0];
        [self.previouslyPlayed removeObjectAtIndex:0];
    } else return; // No previously played songs. Do nothing.
    
    TrackPlayer *newPlayer = [[TrackPlayer alloc] initWithURI:uri delegate:self];
    [self waitForTrackPlayerInitAndPlay:newPlayer];
}

- (void)waitForTrackPlayerInitAndPlay:(TrackPlayer *)player {
    dispatch_queue_t waitForInit = dispatch_queue_create("waitforinit", NULL);
    dispatch_async(waitForInit, ^{
        while (!player.initialized);
        [self setNowPlaying:player];
        [self.nowPlaying play];
    });
}

- (void)setNowPlaying:(TrackPlayer *)nowPlaying {
    _nowPlaying = nowPlaying;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NowPlayingUpdate" object:nil];
}

- (BOOL)isPlaying {
    return [self.nowPlaying isPlaying];
}

#pragma mark Queue Management

- (void)addSongWithURIToQueue:(NSURL *)uri {
    // Inserts uri at the end of the first queue
    [self.firstQueue addObject:uri];
}

// This behavior will probably change
- (void)queuePlaylist:(TrackPlaylist *)playlist shuffled:(BOOL)shuffled{
    if (playlist == nil || [playlist.tracks count] == 0) {
        return;
    }
    
    //TODO Shuffled is currently ignored. Implement this.
    
    for (Track *t in playlist.tracks) {
        [self.secondQueue addObject:t.uri];
    }
    
}

- (void)queuePlaylistAtIndexPath:(NSIndexPath *)indexPath shuffled:(BOOL)shuffled {
    if (indexPath == nil) {
        return;
    }
    
    [self queuePlaylist:[self.playlists objectAtIndex:indexPath.row] shuffled:shuffled];
}

- (void)createPlaylistWithName:(NSString *)name andTrackURI:(NSURL *)uri {
    TrackPlaylist *playlist = [[TrackPlaylist alloc] initWithName:name];
    if (uri) {
        [playlist addTrackWithURI:uri];
    }
    [self.playlists addObject:playlist];
}

#pragma mark TrackPlayerDelegate methods

- (void)trackDidFinishPlaying {
    [self next];
}



@end
