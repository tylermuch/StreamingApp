//
//  TrackPlayer.m
//  StreamingApp
//
//  Created by Tyler  Much on 9/11/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "TrackPlayer.h"
#import "AudioManager.h"
#include "Config.h"
#include "debug.h"

@interface TrackPlayer () <SPTAudioStreamingPlaybackDelegate>

@end

@implementation TrackPlayer

+ (void)trackPlayerWithURI:(NSURL *)uri delegate:(id<TrackPlayerDelegate>)delegate callback:(void (^)(NSError *error, TrackPlayer *player))callback {
    TrackPlayer *newTP = [[TrackPlayer alloc] init];
        newTP.player = nil;
        newTP.track = [[Track alloc] init];
        
        if ([StreamingAppUtil isSpotifyTrackURI:uri]) {
            SPTAudioStreamingController *trackPlayer = [TrackPlayer spotifyStreamingController];
            trackPlayer.playbackDelegate = newTP; //TODO: Implement delegate methods
            if ([[AudioManager sharedInstance] spotifySession] == nil) {
                NSLog(@"SPTSession nil.");
            }
            [trackPlayer loginWithSession:[[AudioManager sharedInstance] spotifySession] callback:^(NSError *error) {
                if (error) {
                    NSLog(@"*** Unable to enable playblack: %@", error);
                    callback(error, nil);
                }
                
                [SPTRequest requestItemAtURI:uri withSession:nil callback:^(NSError *error, id <SPTTrackProvider> provider) {
                    if (error) {
                        NSLog(@"*** Unable to look up track: %@", error);
                        callback(error, nil);
                    }
                    
                    SPTTrack *sptTrack = provider.tracksForPlayback[0]; //TODO: make sure this is correct
                    Track *newTrack = [[Track alloc] init];
                    newTrack.name = sptTrack.name;
                    newTrack.uri = uri;
                    newTrack.duration = sptTrack.duration;
                    newTrack.artist = ((SPTPartialArtist *)sptTrack.artists[0]).name;
                    newTrack.album = sptTrack.album.name;
                    newTP.track = newTrack;
                    newTP.delegate = delegate;
                    newTP.player = trackPlayer;
                    callback(nil, newTP);
                }];
            }];
        } else {
        
            newTP.track.name = [StreamingAppUtil songFromMusicURL:uri];
            newTP.track.uri = uri;
            newTP.track.artist = [StreamingAppUtil artistFromMusicURL:uri];
            newTP.track.album = [StreamingAppUtil albumFromMusicURL:uri];
            AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:uri];
        
            // Subscribe to the AVPlayerItem's DidPlayToEndTime notification.
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
            
            newTP.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
            newTP.delegate = delegate;
            callback(nil, newTP);
        }
}

- (void)play {
    if (self.player == nil) {
        return;
    }
    
    if ([self.player isKindOfClass:[AVPlayer class]]) {
        PLAYBACK_TRACE("Playing with AVPlayer: %@", self.track.name)
        [((AVPlayer *)self.player) play];
    } else if ([self.player isKindOfClass:[SPTAudioStreamingController class]]) {
        PLAYBACK_TRACE("Playing with SPTAudioStreamingController: %@", self.track.name)
        
        SPTAudioStreamingController *tmp = (SPTAudioStreamingController *)self.player;
        // currentTrackMetadata is nil if there is no track currently playing.
        if (tmp.currentTrackMetadata == nil) {
            PLAYBACK_TRACE("Track metadata is nil")
            //should I thread this?
            [SPTRequest requestItemAtURI:self.track.uri withSession:nil callback:^(NSError *error, id <SPTTrackProvider> provider) {
                [tmp playTrackProvider:provider callback:nil]; //TODO: Add callback here?
            }];
        } else {
            [tmp setIsPlaying:YES callback:nil];
        }
        
    } else return;
}

- (void)pause {
    if (self.player == nil) {
        return;
    }
    
    if ([self.player isKindOfClass:[AVPlayer class]]) {
        [((AVPlayer *)self.player) pause];
    } else if ([self.player isKindOfClass:[SPTAudioStreamingController class]]) {
        [((SPTAudioStreamingController *)self.player) setIsPlaying:NO callback:nil];
    } else return;
}

- (BOOL)isPlaying {
    if ([self.player isKindOfClass:[AVPlayer class]]) {
        // AVPlayer rate is 1.0f if it is playing. If it is paused, rate is 0.0f
        return [((AVPlayer *)self.player) rate] == 1.0f;
    } else {
        return [((SPTAudioStreamingController *)self.player) isPlaying];
    }
}

+ (id)spotifyStreamingController {
    __strong static SPTAudioStreamingController *_controller = nil;
    _controller = [[SPTAudioStreamingController alloc] initWithClientId:@kClientId];
    return _controller;
}

#pragma mark AVPlayer delegate methods

// Called when AVPlayer finishes playing a song
-(void)itemDidFinishPlaying:(NSNotification *) notification {
    PLAYBACK_TRACE("Finished playing: %@", notification.object)
    [self.delegate trackDidFinishPlaying];
}


#pragma mark SPTAudioStreamingPlaybackDelegate delegate methods

- (void)audioStreaming:(id)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying {
    PLAYBACK_TRACE("Changed playback status to %@", isPlaying ? @"YES" : @"NO")
    if ([audioStreaming isKindOfClass:[SPTAudioStreamingController class]]) {
        SPTAudioStreamingController *spt = (SPTAudioStreamingController *)audioStreaming;
        if (spt.currentPlaybackPosition == [[spt.currentTrackMetadata objectForKey:SPTAudioStreamingMetadataTrackDuration] doubleValue]) {
            PLAYBACK_TRACE("Spotify song ended")
            [self.delegate trackDidFinishPlaying];
        }
    }
}
@end