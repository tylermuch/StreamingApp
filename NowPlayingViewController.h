//
//  NowPlayingViewController.h
//  StreamingApp
//
//  Created by Tyler Much on 9/21/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioManager.h"


@interface NowPlayingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;
@end
