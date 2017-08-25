//
//  ViewController.m
//  SJVideoPlayerProject
//
//  Created by HarrisDeng on 2017/8/18.
//  Copyright © 2017年 harris. All rights reserved.
//

#import "ViewController.h"

#import "UIView+Extension.h"

#import <Masonry/Masonry.h>

#import "VideoPlayerViewController.h"

#import <Lottie/Lottie.h>

@interface ViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIButton *pushBtn;

@property (nonatomic, strong) LOTAnimationView *lotAniView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.pushBtn];
    [self animaWithName:@"playing" Frame:CGRectMake(120, 350, 180, 180)];
    
    [self.pushBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).mas_offset(200);
    }];
    
}

- (void)clickedBtn:(UIButton *)btn {
    [self.navigationController pushViewController:[VideoPlayerViewController new] animated:YES];
}

- (UIButton *)pushBtn {
    if ( _pushBtn ) return _pushBtn;
    _pushBtn = [UIButton buttonWithTitle:@"Push" titleColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] tag:0 target:self sel:@selector(clickedBtn:) fontSize:14];
    [_pushBtn setImage:[UIImage imageNamed:@"userIcon"] forState:UIControlStateNormal];
    _pushBtn.layer.cornerRadius = 50;
    _pushBtn.clipsToBounds = YES;
    return _pushBtn;
}

- (void)animaWithName:(NSString *)name Frame:(CGRect )frame{
    if (!self.lotAniView) {
        LOTAnimationView *animationView = [LOTAnimationView animationNamed:name];
        [animationView setFrame:frame];
//        [animationView addSubview:self.view];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedBtn:)];
        tap.delegate = self;
        [animationView addGestureRecognizer:tap];
        
        animationView.loopAnimation = YES;
        animationView.contentMode = UIViewContentModeScaleAspectFill;
        animationView.animationSpeed = 0.5;
        animationView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [UIView animateWithDuration:3.0 delay:0.0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse animations:^{
            animationView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self.view addSubview:animationView];
            [animationView play];
        }];
            self.lotAniView = animationView;
    }

}


@end
