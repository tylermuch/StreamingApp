//
//  TrackPlaylist.m
//  StreamingApp
//
//  Created by Tyler  Much on 9/11/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "TrackPlaylist.h"

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
    track.name = [StreamingAppUtil songFromMusicURL:uri];
    track.uri = uri;
    track.artist = [StreamingAppUtil artistFromMusicURL:uri];
    track.album = [StreamingAppUtil albumFromMusicURL:uri];
    track.duration = 0;
    [self.tracks addObject:track];
}

- (void)removeTrackAtIndex:(NSUInteger)index {
    [self.tracks removeObjectAtIndex:index];
}

@end
