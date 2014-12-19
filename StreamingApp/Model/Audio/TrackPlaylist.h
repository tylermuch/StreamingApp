//
//  TrackPlaylist.h
//  StreamingApp
//
//  Created by Tyler  Much on 9/11/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Track.h"
#import "StreamingAppUtil.h"

@interface TrackPlaylist : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *tracks; //of Track

- (id)initWithName:(NSString *)name;
- (void)addTrack:(Track *)track;
- (void)addTrackWithURI:(NSURL *)uri;
- (void)removeTrackAtIndex:(NSUInteger)index;

@end
