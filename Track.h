//
//  Track.h
//  StreamingApp
//
//  Created by Tyler  Much on 9/11/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Track : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL *uri;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *album;

@end
