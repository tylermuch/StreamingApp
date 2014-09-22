//
//  TrackPlayer.h
//  StreamingApp
//
//  Created by Tyler  Much on 9/11/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Track.h"
#import "TrackPlayer.h"
#import "TrackPlaylist.h"
#import "StreamingAppUtil.h"
#import <AVFoundation/AVFoundation.h>

@protocol TrackPlayerDelegate <NSObject>

- (void)trackDidFinishPlaying;

@end

@interface TrackPlayer : NSObject

@property (nonatomic, strong) Track *track;
@property (nonatomic, strong) NSObject *player;
@property (nonatomic) BOOL initialized;
@property (nonatomic) id <TrackPlayerDelegate> delegate;

- (id)initWithURI:(NSURL *)uri delegate:(id <TrackPlayerDelegate>)delegate;
- (void)play;
- (void)pause;
- (BOOL)isPlaying;

@end
