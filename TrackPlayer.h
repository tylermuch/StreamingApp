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

@interface TrackPlayer : NSObject

@property (nonatomic, strong) Track *track;
@property (nonatomic, strong) NSObject *player;
@property (nonatomic) BOOL initialized;

- (id)initWithURI:(NSURL *)uri;
- (void)play;
- (void)pause;

@end
