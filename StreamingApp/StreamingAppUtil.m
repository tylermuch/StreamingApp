//
//  StreamingAppUtil.m
//  StreamingApp
//
//  Created by Tyler  Much on 9/2/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "StreamingAppUtil.h"
#import "JFUrlUtil.h"

//static NSString * const baseURL = @"http://www.tylermuch.com";
static NSString * const baseURL = @"http://localhost";

@implementation StreamingAppUtil

+ (NSURL *)urlForArtist:(NSString *)artist album:(NSString *)album {
    NSMutableString *urlString = [baseURL mutableCopy];
    [urlString appendString:@":5000/list"];
    
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

+ (NSURL *)musicUrlForArtist:(NSString *)artist album:(NSString *)album song:(NSString *)song{
    if (artist == nil || album == nil || song == nil) {
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"music/%@/%@/%@", artist, album, song];
    return [NSURL URLWithString:[JFUrlUtil encodeUrl:urlString] relativeToURL:[NSURL URLWithString:baseURL]];
}

// TODO: Fix this to be more flexible.
+ (NSString *)artistFromMusicURL:(NSURL *)url {
    return [StreamingAppUtil partsOfURL:url][2];
}

+ (NSString *)albumFromMusicURL:(NSURL *)url {
    return [StreamingAppUtil partsOfURL:url][3];
}

+ (NSString *)songFromMusicURL:(NSURL *)url {
    return [StreamingAppUtil partsOfURL:url][4];
}

+ (NSArray *)partsOfURL:(NSURL *)url {
    NSString *s = url.absoluteString;
    s = [s stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    s = [s stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [s componentsSeparatedByString:@"/"];
}

@end
