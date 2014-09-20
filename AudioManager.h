//
//  AudioManager.h
//  StreamingApp
//
//  Created by Tyler  Much on 9/11/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Track.h"
#import "TrackPlayer.h"
#import "TrackPlaylist.h"

@interface AudioManager : NSObject

@property (nonatomic, strong) TrackPlayer *nowPlaying;

/*
    firstQueue is where any song will go that is placed individually into the queue.
 */
@property (nonatomic, strong) NSMutableArray *firstQueue; // of NSURL

/*
    When a playlist or album is played, its songs will be placed into the secondQueue. The songs in secondQueue will only play when there are zero songs in firstQueue. This is to mimic the behavior of Spotify's queueing system which I happen to like :)
 */
@property (nonatomic, strong) NSMutableArray *secondQueue; // of NSURL

@property (nonatomic, strong) NSMutableArray *playlists; // of TrackPlaylist

+ (id)sharedInstance;

/*
    A convenience method so that ViewControllers don't have to worry about creating a track. This just creates and Track and passes that to addSong:toPlaylist
 */
- (void)addSongWithURIToQueue:(NSURL *)uri;
- (void)play;
- (void)pause;
- (void)next;
- (void)previous;
- (void)playPlaylist:(TrackPlaylist *)playlist shuffled:(BOOL)shuffled;
- (void)createPlaylistWithName:(NSString *)name andTrackURI:(NSURL *)uri;

@end
