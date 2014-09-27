//
//  TrackPlaylist.m
//  StreamingApp
//
//  Created by Tyler  Much on 9/11/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "TrackPlaylist.h"
#import "TrackPlayer.h"
#import "AudioManager.h"

@implementation TrackPlaylist

- (id)initWithName:(NSString *)name {
    if (name == nil || [name isEqualToString:@""]) {
        return nil;
    }
    
    if (self = [super init]) {
        _name = name;
        _tracks = [[NSMutableArray alloc] init];
        return self;
    }
    return nil;
}

- (void)addTrack:(Track *)track {
    [self.tracks addObject:track];
}

- (void)addTrackWithURI:(NSURL *)uri {
    Track *track = [[Track alloc] init];
    
    if ([StreamingAppUtil isSpotifyURI:uri]) {
        [[TrackPlayer spotifyStreamingController] loginWithSession:[[AudioManager sharedInstance] spotifySession] callback:^(NSError *error) {
            if (error) {
                NSLog(@"*** Unable to enable playblack: %@", error);
                return;
            }
            
            [SPTRequest requestItemAtURI:uri withSession:nil callback:^(NSError *error, id <SPTTrackProvider> provider) {
                if (error) {
                    NSLog(@"*** Unable to look up track: %@", error);
                    return;
                }
                
                SPTTrack *sptTrack = provider.tracksForPlayback[0]; //TODO: make sure this is correct
                Track *newTrack = [[Track alloc] init];
                newTrack.name = sptTrack.name;
                newTrack.uri = uri;
                newTrack.duration = sptTrack.duration;
                newTrack.artist = ((SPTPartialArtist *)sptTrack.artists[0]).name;
                newTrack.album = sptTrack.album.name;
                [self.tracks addObject:newTrack];
            }];
        }];

    } else {
        track.name = [StreamingAppUtil songFromMusicURL:uri];
        track.uri = uri;
        track.artist = [StreamingAppUtil artistFromMusicURL:uri];
        track.album = [StreamingAppUtil albumFromMusicURL:uri];
        track.duration = 0;
        [self.tracks addObject:track];
    }
}

- (void)removeTrackAtIndex:(NSUInteger)index {
    [self.tracks removeObjectAtIndex:index];
}

@end
