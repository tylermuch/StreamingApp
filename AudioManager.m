//
//  AudioManager.m
//  StreamingApp
//
//  Created by Tyler  Much on 9/11/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "AudioManager.h"

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
        self.firstQueue = [[NSMutableArray alloc] init];
        self.firstQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
