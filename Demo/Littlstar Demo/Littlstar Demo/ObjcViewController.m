//
//  UIViewController+ObjcViewController.m
//  Littlstar Demo
//
//  Created by Isabel Lee on 12/20/17.
//  Copyright © 2017 Huy Dao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjcViewController.h"
@import ls_ios_sdk;

@interface ObjectiveCViewController() <LSPlayerDelegate>

@end

@implementation ObjectiveCViewController

LSPlayer *player;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize LSPlayer
    player = [[LSPlayer alloc] initWithFrame:self.view.frame withMenu:true];
    player.delegate = self;
    [self.view addSubview:player];
    
    // Initialize Media
    [player initMedia:[NSURL URLWithString:@"https://videos.littlstar.com/76b490a5-2125-4281-b52d-8198ab0e817d/mobile_1513415818.mp4"] withHeatmap:false];
}

// Conform to the LSPlayerDelegate protocol and implement all required and/or optional delegate methods
- (void)lsPlayerReadyWithVideoWithDuration:(double)duration {
    NSLog(@"Player is ready to display the 360 video");
    [player play];
}

- (void)lsPlayerHasEnded {
    NSLog(@"Video has ended");
    //[player close];
    [player playLongerAnimationWithCompletionCallback:^{
        [player close];
    }];
}

- (void)lsPlayerReadyWithImage {
    NSLog(@"Player is ready to display the image");
}

- (void)lsPlayerWithIsBuffering:(BOOL)isBuffering {
    if (isBuffering) {
        NSLog(@"Player is buffering");
    } else {
        NSLog(@"Player is not buffering");
    }
}

- (void)lsPlayerHasUpdatedWithCurrentTime:(double)currentTime bufferedTime:(double)bufferedTime {
    NSLog(@"Player has updated its state");
}

- (void)lsPlayerDidTap {
    [player setVRModeWithEnable:true];
}
@end


