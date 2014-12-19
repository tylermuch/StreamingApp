//
//  NowPlayingViewController.m
//  StreamingApp
//
//  Created by Tyler Much on 9/21/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import "NowPlayingViewController.h"
#include "debug.h"

@implementation NowPlayingViewController
- (IBAction)playPressed:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        AudioManager *am = [AudioManager sharedInstance];
        if ([am isPlaying]) {
            [am pause];
            [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
        } else {
            [am play];
            [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
        }
    }
}

- (IBAction)prevPressed:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        AudioManager *am = [AudioManager sharedInstance];
        [am previous];
    }
}

- (IBAction)nextPressed:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        AudioManager *am = [AudioManager sharedInstance];
        [am next];
    }
}
- (IBAction)sliderChanged:(id)sender {
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([[AudioManager sharedInstance] isPlaying]) {
        [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
    } else {
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
    }
    
    [self.songNameLabel setText:[[AudioManager sharedInstance] nowPlaying].track.name];
    [self.artistLabel setText:[[AudioManager sharedInstance] nowPlaying].track.artist];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nowPlayingChanged:) name:@"NowPlayingUpdate" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)nowPlayingChanged:(NSNotification *)notification {
    UI_TRACE("Updating now playing labels")
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.songNameLabel setText:[[AudioManager sharedInstance] nowPlaying].track.name];
        [self.artistLabel setText:[[AudioManager sharedInstance] nowPlaying].track.artist];
        [self.timeSlider setValue:0 animated:YES];
        [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
    });
}

@end
