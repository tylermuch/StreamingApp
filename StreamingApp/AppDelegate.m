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
#include "Config.h"
#include "debug.h"

static NSString * const kSessionUserDefaultsKey = @"AppStreamingSpotifySession";

@implementation AppDelegate

- (void)storeSessionInUserDefaults:(SPTSession *)session {
    SPOTIFY_TRACE("Storing sessions in user defaults")
    NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:session];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:sessionData forKey:kSessionUserDefaultsKey];
    [userDefaults synchronize];
}

- (void)initializeSpotifySession {
    SPOTIFY_TRACE("Initializing spotify session.")
    
    id sessionData = [[NSUserDefaults standardUserDefaults] objectForKey:kSessionUserDefaultsKey];
    SPTSession *session = sessionData ? [NSKeyedUnarchiver unarchiveObjectWithData:sessionData] : nil;
    
    if (session) {
        if ([session isValid]) {
            SPOTIFY_TRACE("Found valid session in NSUserDefaults")
            [self storeSessionInUserDefaults:session];
            [[AudioManager sharedInstance] setSpotifySession:session];
        } else {
            SPOTIFY_TRACE("Found invalid session in NSUserDefaults.")
            if (@kTokenRefreshServiceURL == nil || [@kTokenRefreshServiceURL isEqualToString:@""]) {
                [self openLoginPage];
            } else {
                [self renewToken];
            }
        }
    } else {
        SPOTIFY_TRACE("Did not find session in NSUserDefaults.")
        [self openLoginPage];
    }
}

- (void)openLoginPage {
    SPOTIFY_TRACE("Spawning Spotify login page.")
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    NSURL *loginURL;
    if (@kTokenSwapServiceURL == nil || [@kTokenSwapServiceURL isEqualToString:@""]) {
        loginURL = [auth loginURLForClientId:@kClientId declaredRedirectURL:[NSURL URLWithString:@kCallbackURL] scopes:@[SPTAuthStreamingScope] withResponseType:@"token"];
    } else {
        loginURL = [auth loginURLForClientId:@kClientId declaredRedirectURL:[NSURL URLWithString:@kCallbackURL] scopes:@[SPTAuthStreamingScope]];
    }
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] openURL:loginURL];
    });
}

- (void)renewToken {
    SPOTIFY_TRACE("Renewing spotify token.")
    id sessionData = [[NSUserDefaults standardUserDefaults] objectForKey:kSessionUserDefaultsKey];
    SPTSession *session = sessionData ? [NSKeyedUnarchiver unarchiveObjectWithData:sessionData] : nil;
    SPTAuth *auth = [SPTAuth defaultInstance];
    [auth renewSession:session withServiceEndpointAtURL:[NSURL URLWithString:@kTokenRefreshServiceURL] callback:^(NSError *error, SPTSession *session) {
        if (error) {
            SPOTIFY_TRACE("*** Error renewing session: %@", error)
            return;
        }
        [self storeSessionInUserDefaults:session];
        SPOTIFY_TRACE("Setting global spotify session.")
        [[AudioManager sharedInstance] setSpotifySession:session];
    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Enable background audio playback
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    [self initializeSpotifySession];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
        NSLog(@"auth callback.");
        if (error != nil) {
            NSLog(@"*** Auth error: %@", error);
            return;
        }
        NSLog(@"setting spotify session");
        [self storeSessionInUserDefaults:session];
        [[AudioManager sharedInstance] setSpotifySession:session];
    };
    
    
    if ([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL:[NSURL URLWithString:@kCallbackURL]]) {
        NSLog(@"Spotify auth can handle URL");
        if (@kTokenSwapServiceURL == nil || [@kTokenSwapServiceURL isEqualToString:@""]) {
            NSLog(@"handle auth callback");
            [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:authCallback];
        } else {
            // If we have a token exchange service, we'll call it and get the token.
            NSLog(@"handle auth callback with token swap");
            [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url
                                                tokenSwapServiceEndpointAtURL:[NSURL URLWithString:@kTokenSwapServiceURL]
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
