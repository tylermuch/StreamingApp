//
//  AudioManager.m
//  StreamingApp
//
//  Created by Tyler  Much on 9/11/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "AudioManager.h"
#include "debug.h"

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
    [TrackPlayer trackPlayerWithURI:uri delegate:self callback:^(NSError *error, TrackPlayer *player) {
        if (error) {
            PLAYBACK_TRACE("Error initializing track: %@", error)
            return;
        }
        
        self.nowPlaying = player;
        [self.nowPlaying play];
    }];
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
    
    // Silence the currently playing player. This is really only necessary for the Spotify player.
    // If it is not silenced here and the next song is AVPlayer, the spotify song will keep playing.
    [self pause];
    //TrackPlayer *newPlayer = [[TrackPlayer alloc] initWithURI:uri delegate:self];
    [TrackPlayer trackPlayerWithURI:uri delegate:self callback:^(NSError *error, TrackPlayer *player) {
        if (error) {
            PLAYBACK_TRACE("Error initializing track: %@", error)
            return;
        }
        
        self.nowPlaying = player;
        [self.nowPlaying play];
    }];
    
}

- (void)previous {
    NSURL *uri = nil;
    if ([self.previouslyPlayed count] > 0) {
        uri = [self.previouslyPlayed objectAtIndex:0];
        [self.previouslyPlayed removeObjectAtIndex:0];
    } else return; // No previously played songs. Do nothing.
    
    //TrackPlayer *newPlayer = [[TrackPlayer alloc] initWithURI:uri delegate:self];
    [TrackPlayer trackPlayerWithURI:uri delegate:self callback:^(NSError *error, TrackPlayer *player) {
        if (error) {
            PLAYBACK_TRACE("Error initializing track: %@", error)
            return;
        }
        
        self.nowPlaying = player;
        [self.nowPlaying play];
    }];
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

- (void)queueAlbum:(NSString *)album artist:(NSString *)artist {
    NSURL *url = [StreamingAppUtil urlForArtist:artist album:album];
    
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    
    dispatch_queue_t jsonFetch = dispatch_queue_create("json fetch", NULL);
    dispatch_async(jsonFetch, ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
        });
        
        NSError *error = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (error != nil) {
            SERVER_TRACE("Error parsing JSON.")
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (NSString *song in [jsonArray copy]) {
                    NSURL *musicURL = [StreamingAppUtil musicUrlForArtist:artist album:album song:song];
                    [[[AudioManager sharedInstance] secondQueue] addObject:musicURL];
                }
            });
        }
    });
}

- (void)queueSpotifyAlbum:(NSURL *)uri {
    [SPTRequest requestItemAtURI:uri withSession:[[AudioManager sharedInstance] spotifySession] callback:^(NSError *error, SPTAlbum *album) {
        if (error) {
            SPOTIFY_TRACE("Error getting full spotify album: %@", error)
        }
        
        for (SPTPartialTrack *t in album.firstTrackPage.items) {
            [[[AudioManager sharedInstance] secondQueue] addObject:t.uri];
        }
        
    }];
}

- (void)playAlbum:(NSString *)album artist:(NSString *)artist {
    NSURL *url = [StreamingAppUtil urlForArtist:artist album:album];
    
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    
    dispatch_queue_t jsonFetch = dispatch_queue_create("json fetch", NULL);
    dispatch_async(jsonFetch, ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
        });
        
        NSError *error = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (error != nil) {
            SERVER_TRACE("Error parsing JSON")
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *first = [[jsonArray copy] firstObject];
                for (NSString *song in [jsonArray copy]) {
                    if ([song isEqualToString:first]) {
                        continue;
                    }
                    NSURL *musicURL = [StreamingAppUtil musicUrlForArtist:artist album:album song:song];
                    [[[AudioManager sharedInstance] secondQueue] addObject:musicURL];
                }
                [[AudioManager sharedInstance] playSongWithURI:[StreamingAppUtil musicUrlForArtist:artist album:album song:first]];
            });
        }
    });
}

- (void)playSpotifyAlbum:(NSURL *)uri {
    [SPTRequest requestItemAtURI:uri withSession:[[AudioManager sharedInstance] spotifySession] callback:^(NSError *error, SPTAlbum *album) {
        if (error) {
            SPOTIFY_TRACE("Error getting full spotify album: %@", error)
        }
        
        NSURL *firstTrack = ((SPTPartialTrack *)([album.firstTrackPage.items firstObject])).uri;
        for (SPTPartialTrack *t in album.firstTrackPage.items) {
            if ([[t.uri absoluteString] isEqualToString:[firstTrack absoluteString]]) {
                continue;
            }
            [[[AudioManager sharedInstance] secondQueue] addObject:t.uri];
        }
        
        [[AudioManager sharedInstance] playSongWithURI:firstTrack];
    }];
}

#pragma mark TrackPlayerDelegate methods

- (void)trackDidFinishPlaying {
    [self next];
}



@end
