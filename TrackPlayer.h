//
//  TrackPlayer.h
//  StreamingApp
//
//  Created by Tyler  Much on 9/11/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Track.h"
#import "TrackPlaylist.h"
#import "StreamingAppUtil.h"
#import <AVFoundation/AVFoundation.h>
#import <Spotify/Spotify.h>

@protocol TrackPlayerDelegate <NSObject>

- (void)trackDidFinishPlaying;

@end

@interface TrackPlayer : NSObject

@property (nonatomic, strong) Track *track;
@property (nonatomic, strong) NSObject *player;
@property (nonatomic) id <TrackPlayerDelegate> delegate;

+ (void)trackPlayerWithURI:(NSURL *)uri
                  delegate:(id<TrackPlayerDelegate>)delegate
                  callback:(void (^)(NSError *error, TrackPlayer *player))callback;
- (void)play;
- (void)pause;
- (BOOL)isPlaying;

+ (id)spotifyStreamingController;

@end
