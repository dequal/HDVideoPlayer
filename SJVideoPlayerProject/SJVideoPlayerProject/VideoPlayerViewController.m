//
//  VideoPlayerViewController.m
//  SJVideoPlayerProject
//
//  Created by HarrisDeng on 2017/8/18.
//  Copyright © 2017年 harris. All rights reserved.
//

#import "VideoPlayerViewController.h"

#import "SJVideoPlayer.h"

#import <Masonry.h>

@interface VideoPlayerViewController ()

@end

@implementation VideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor =  [UIColor colorWithRed:39/255.0 green:50/255.0 blue:56/255.0 alpha:1/1.0];
    
    SJVideoPlayer *player = [SJVideoPlayer sharedPlayer];
    
//    player.assetURL = [[NSBundle mainBundle] URLForResource:@"sample.mp4" withExtension:nil];
    
    player.assetURL = [NSURL URLWithString:@"http://pic.ibaotu.com/00/15/20/888piC8n888piCHFX.mp4"];
    
    [self.view addSubview:player.view];
    
    [player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(64);
        make.leading.trailing.offset(0);
        make.height.equalTo(player.view.mas_width).multipliedBy(9.0 / 16.0);
    }];
    
    // Do any additional setup after loading the view.
}

@end
