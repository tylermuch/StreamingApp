//
//  StreamingAppUtil.h
//  StreamingApp
//
//  Created by Tyler  Much on 9/2/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StreamingAppUtil : NSObject

+ (NSURL *)urlForArtist:(NSString *)artist album:(NSString *)album;

@end
