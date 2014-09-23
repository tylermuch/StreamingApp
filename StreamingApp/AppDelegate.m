//
//  AppDelegate.m
//  StreamingApp
//
//  Created by Tyler Much on 9/1/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioManager.h"

static NSString * const kClientId = @"9d29a3c980c4430c89047224e3d6cfa3";
static NSString * const kCallbackURL = @"streaming-app://callback";
static NSString * const kTokenSwapServiceURL = @"http://tylermuch.com:5001/swap"; // token exchange service
static NSString * const kTokenRefreshServiceURL = @"http://tylermuch.com:1234/refresh"; // token refresh service

@implementation AppDelegate

- (void)openLoginPage {
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    NSURL *loginURL;
    if (kTokenSwapServiceURL == nil || [kTokenSwapServiceURL isEqualToString:@""]) {
        loginURL = [auth loginURLForClientId:kClientId declaredRedirectURL:[NSURL URLWithString:kCallbackURL] scopes:@[SPTAuthStreamingScope] withResponseType:@"token"];
    } else {
        loginURL = [auth loginURLForClientId:kClientId declaredRedirectURL:[NSURL URLWithString:kCallbackURL] scopes:@[SPTAuthStreamingScope]];
    }
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] openURL:loginURL];
    });
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Enable background audio playback
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    // TODO: Check for existing session in NSUserDefaults
    [self openLoginPage];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
        if (error != nil) {
            NSLog(@"*** Auth error: %@", error);
            return;
        }
        
        [[AudioManager sharedInstance] setSpotifySession:session];
    };
    
    if ([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL:[NSURL URLWithString:kCallbackURL]]) {
        if (kTokenSwapServiceURL == nil || [kTokenSwapServiceURL isEqualToString:@""]) {
            [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:authCallback];
        } else {
            // If we have a token exchange service, we'll call it and get the token.
            [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url
                                                tokenSwapServiceEndpointAtURL:[NSURL URLWithString:kTokenSwapServiceURL]
                                                                     callback:authCallback];
        }
        return YES;
    }
    return NO;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
