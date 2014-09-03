//
//  StreamingAppUtil.m
//  StreamingApp
//
//  Created by Tyler  Much on 9/2/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "StreamingAppUtil.h"
#import "JFUrlUtil.h"

static NSString * const baseURL = @"http://www.tylermuch.com:5000/";

@implementation StreamingAppUtil

+ (NSURL *)urlForArtist:(NSString *)artist album:(NSString *)album {
    NSMutableString *urlString = [baseURL mutableCopy];
    [urlString appendString:@"list"];
    
    // We cannot handle this case. An artist must be specified with the album.
    if ( (artist == nil) && (album != nil)) {
        return nil;
    }
    
    if (artist != nil) {
        [urlString appendString:@"/"];
        [urlString appendString:artist];
    }
    
    if (album != nil) {
        [urlString appendString:@"/"];
        [urlString appendString:album];
    }
    
    NSString *encodedURL = [JFUrlUtil encodeUrl:urlString];
    return [NSURL URLWithString:encodedURL];
}

@end
