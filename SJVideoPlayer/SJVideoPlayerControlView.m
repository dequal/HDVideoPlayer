//
//  SJVideoPlayerControlView.m
//  SJVideoPlayerProject
//
//  Created by HarrisDeng on 2017/8/18.
//  Copyright © 2017年 harris. All rights reserved.
//

#import "SJVideoPlayerControlView.h"

#import <SJSlider/SJSlider.h>

#import <UIKit/UIKit.h>

#import "UIView+Extension.h"

#import <Masonry/Masonry.h>

#import "NSAttributedString+ZFBAdditon.h"

#import <objc/message.h>

#import "NSTimer+SJExtention.h"


@interface SJMaskView : UIView
@end


static NSString *const SJVideoPlayPreviewColCellID = @"SJVideoPlayPreviewColCell";

@protocol SJVideoPlayPreviewColCellDelegate;

@interface SJVideoPlayPreviewColCell : UICollectionViewCell
@property (nonatomic, strong, readwrite) SJVideoPreviewModel *model;
@property (nonatomic, weak) id <SJVideoPlayPreviewColCellDelegate> delegate;
@end

@protocol SJVideoPlayPreviewColCellDelegate <NSObject>
@optional
- (void)clickedItemOnCell:(SJVideoPlayPreviewColCell *)cell;
@end


@interface SJVideoPlayerControlView (PreviewCellDelegateMethods)<SJVideoPlayPreviewColCellDelegate>

@end

@interface SJVideoPlayerControlView (ColDataSourceMethods)<UICollectionViewDataSource>
@end




// MARK: 观察处理

@interface SJVideoPlayerControlView (DBObservers)

- (void)_SJVideoPlayerControlViewObservers;

- (void)_SJVideoPlayerControlViewRemoveObservers;

@end




@interface SJVideoPlayerControlView ()

// MARK: ...

@property (nonatomic, strong, readonly) UIView *topContainerView;
@property (nonatomic, strong, readonly) UIButton *backBtn;
@property (nonatomic, strong, readonly) UIButton *previewBtn;
@property (nonatomic, strong, readonly) UICollectionView *previewImgColView;


// MARK: ...
@property (nonatomic, strong, readonly) UIButton *replayBtn;
@property (nonatomic, strong, readonly) UIView *lockBtnContainerView;
@property (nonatomic, strong, readonly) UIButton *unlockBtn;
@property (nonatomic, strong, readonly) UIButton *lockBtn;


// MARK: ...
@property (nonatomic, strong, readonly) SJMaskView *bottomContainerView;
@property (nonatomic, strong, readonly) UIButton *playBtn;
@property (nonatomic, strong, readonly) UIButton *pauseBtn;
@property (nonatomic, strong, readonly) UIButton *fullBtn;
@property (nonatomic, strong, readonly) UILabel *currentTimeLabel;
@property (nonatomic, strong, readonly) UILabel *separateLabel;
@property (nonatomic, strong, readonly) UILabel *durationTimeLabel;


// MARK: ...
@property (nonatomic, strong, readwrite) UITapGestureRecognizer *singleTap;



// MARK: ...
@property (nonatomic, assign, readwrite) BOOL isHiddenControl;
@property (nonatomic, assign, readwrite) NSInteger hiddenControlPoint;
@property (nonatomic, strong, readonly) NSTimer *pointTimer;


// MARK: ...
@property (nonatomic, strong, readonly) UIButton *loadFailedBtn;

// MARK: ...
@property (nonatomic, strong, readonly) SJSlider *bottomProgressView;


@end

@implementation SJVideoPlayerControlView

// MARK: ...
@synthesize topContainerView = _topContainerView;
@synthesize backBtn = _backBtn;
@synthesize previewBtn = _previewBtn;
@synthesize previewImgColView = _previewImgColView;

// MARK: ...
@synthesize replayBtn = _replayBtn;
@synthesize lockBtnContainerView = _lockBtnContainerView;
@synthesize unlockBtn = _unlockBtn;
@synthesize lockBtn = _lockBtn;

// MARK: ...
@synthesize bottomContainerView = _bottomContainerView;
@synthesize playBtn = _playBtn;
@synthesize pauseBtn = _pauseBtn;
@synthesize fullBtn = _fullBtn;
@synthesize currentTimeLabel = _currentTimeLabel;
@synthesize separateLabel = _separateLabel;
@synthesize durationTimeLabel = _durationTimeLabel;
@synthesize sliderControl = _sliderControl;

// MARK: ...
@synthesize pointTimer = _pointTimer;

// MARK: ...
@synthesize draggingTimeLabel = _draggingTimeLabel;
@synthesize draggingProgressView = _draggingProgressView;

// MARK: ...
@synthesize loadFailedBtn = _loadFailedBtn;

// MARK: ...
@synthesize bottomProgressView = _bottomProgressView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJVideoPlayerControlViewSetupUI];
    [self _SJVideoPlayerControlViewObservers];
    [self pointTimer];
    return self;
}

- (void)dealloc {
    [self _SJVideoPlayerControlViewRemoveObservers];
}

// MARK: Actions

- (void)clickedBtn:(UIButton *)btn {
    // preview anima
    if ( btn == self.previewBtn ) {
        if ( !btn.selected ) {
            [self previewImgColView_ShowAnima];
            
            [_pointTimer invalidate];
            _pointTimer = nil;
        }
        else {
            [self previewImgColView_HiddenAnima];
            
            [self.pointTimer fire];
        }
    }
    
    if ( ![self.delegate respondsToSelector:@selector(controlView:clickedBtnTag:)] ) return;
    [self.delegate controlView:self clickedBtnTag:btn.tag];
}

// MARK: Anima

- (void)previewImgColView_ShowAnima {
    [UIView animateWithDuration:0.3 animations:^{
        self.previewImgColView.transform = CGAffineTransformIdentity;
        self.previewImgColView.alpha = 1.0;
    }];
    self.previewBtn.selected = YES;
}

- (void)previewImgColView_HiddenAnima {
    [UIView animateWithDuration:0.3 animations:^{
        self.previewImgColView.transform = CGAffineTransformMakeScale(1, 0.001);
        self.previewImgColView.alpha = 0.001;
    }];
    self.previewBtn.selected = NO;
}

- (void)showController {
    [UIView animateWithDuration:0.3 animations:^{
        self.topContainerView.transform = CGAffineTransformIdentity;
        self.bottomContainerView.transform = CGAffineTransformIdentity;
        self.topContainerView.alpha = 1;
        self.bottomContainerView.alpha = 1;
    }];
    
    [self.pointTimer fire];
    
    self.hiddenControlPoint = 0;
    
    self.hiddenBottomProgressView = YES;
}

- (void)hiddenController {

    [UIView animateWithDuration:0.3 animations:^{
        self.topContainerView.transform = CGAffineTransformMakeTranslation(0, -SJContainerH);
        self.bottomContainerView.transform = CGAffineTransformMakeTranslation(0, SJContainerH);
        self.topContainerView.alpha = 0.001;
        self.bottomContainerView.alpha = 0.001;
    }];
    
    [_pointTimer invalidate];
    _pointTimer = nil;
    
    self.hiddenControlPoint = 0;
    
    self.hiddenBottomProgressView = NO;
}


// MARK: UI

- (void)_SJVideoPlayerControlViewSetupUI {
    
    self.clipsToBounds = YES;
    
    // MARK: ...
    [self addSubview:self.topContainerView];
    [_topContainerView addSubview:self.backBtn];
    [_topContainerView addSubview:self.previewBtn];
    
    [self addSubview:self.previewImgColView];
    
    [_previewImgColView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.offset(SJPreViewImgH);
        make.leading.trailing.offset(0);
        make.top.equalTo(_topContainerView.mas_bottom);
    }];
    
    [_topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.offset(0);
        make.height.offset(SJContainerH);
    }];
    
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.offset(0);
        make.width.equalTo(_backBtn.mas_height);
    }];
    
    [_previewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.trailing.offset(0);
        make.width.equalTo(_previewBtn.mas_height);
    }];
    
    
    // MARK: ...
    [self addSubview:self.replayBtn];
    [self addSubview:self.lockBtnContainerView];
    [self.lockBtnContainerView addSubview:self.lockBtn];
    [self.lockBtnContainerView addSubview:self.unlockBtn];
    
    [_lockBtnContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(0);
        make.width.height.offset(44);
        make.centerY.equalTo(_lockBtnContainerView.superview);
    }];
    
    [_lockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_unlockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_replayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    
    
    // MARK: ...
    [self addSubview:self.bottomContainerView];
    [_bottomContainerView addSubview:self.fullBtn];
    [_bottomContainerView addSubview:self.playBtn];
    [_bottomContainerView addSubview:self.pauseBtn];
    [_bottomContainerView addSubview:self.currentTimeLabel];
    [_bottomContainerView addSubview:self.separateLabel];
    [_bottomContainerView addSubview:self.durationTimeLabel];
    [_bottomContainerView addSubview:self.sliderControl];
    
    [_bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.offset(0);
        make.height.offset(SJContainerH);
    }];
    
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.offset(0);
        make.width.equalTo(_playBtn.mas_height);
    }];
    
    [_pauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_playBtn);
    }];
    
    [_fullBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.bottom.offset(0);
        make.width.equalTo(_fullBtn.mas_height);
    }];
    
    [_currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_separateLabel);
        make.leading.equalTo(_playBtn.mas_trailing);
    }];
    
    [_separateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_separateLabel.superview);
        make.leading.equalTo(_currentTimeLabel.mas_trailing);
    }];
    
    [_durationTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_separateLabel.mas_trailing);
        make.centerY.equalTo(_separateLabel);
    }];
    
    [_sliderControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_playBtn.mas_trailing).offset(90);
        make.trailing.equalTo(_fullBtn.mas_leading).offset(-8);
        make.top.bottom.offset(0);
    }];
    
    
    // MARK: ...
    [self addSubview:self.draggingTimeLabel];
    [self addSubview:self.draggingProgressView];
    
    _draggingTimeLabel.text = @"00:00";
    [_draggingTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_draggingTimeLabel.superview);
        make.bottom.equalTo(_draggingTimeLabel.superview.mas_centerY).offset(-8);
    }];
    
    [_draggingProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(130);
        make.height.offset(3);
        make.center.offset(0);
    }];
    
    
    // MARK: ...
    [self addSubview:self.loadFailedBtn];
    [_loadFailedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    // MARK: ...
    [self addSubview:self.bottomProgressView];
    [_bottomProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(0);
        make.leading.offset(-1);
        make.trailing.offset(1);
        make.height.offset(1);
    }];
}

// MARK: ...

- (UIView *)topContainerView {
    if ( _topContainerView ) return _topContainerView;
    _topContainerView = [UIView new];
    _topContainerView.backgroundColor = [UIColor clearColor];
    return _topContainerView;
}

- (UIButton *)backBtn {
    if ( _backBtn ) return _backBtn;
    _backBtn = [UIButton buttonWithImageName:@"sj_video_player_back" tag:SJVideoPlayControlViewTag_Back target:self sel:@selector(clickedBtn:)];
    return _backBtn;
}

- (UIButton *)previewBtn {
    if ( _previewBtn ) return _previewBtn;
    _previewBtn = [UIButton buttonWithTitle:@"预览" backgroundColor:[UIColor clearColor] tag:SJVideoPlayControlViewTag_Preview target:self sel:@selector(clickedBtn:) fontSize:14];
    return _previewBtn;
}

- (UICollectionView *)previewImgColView {
    if ( _previewImgColView ) return _previewImgColView;
    _previewImgColView = [UICollectionView collectionViewWithItemSize:CGSizeMake(SJPreviewImgW, SJPreViewImgH) backgroundColor:[UIColor blackColor] scrollDirection:UICollectionViewScrollDirectionHorizontal];
    _previewImgColView.dataSource = self;
    [_previewImgColView registerClass:NSClassFromString(SJVideoPlayPreviewColCellID) forCellWithReuseIdentifier:SJVideoPlayPreviewColCellID];
    _previewImgColView.transform = CGAffineTransformMakeScale(1, 0.001);
    _previewImgColView.alpha = 0.001;
    return _previewImgColView;
}

// MARK: ...

- (UIButton *)replayBtn {
    if ( _replayBtn ) return _replayBtn;
    _replayBtn = [UIButton buttonWithTitle:@"" backgroundColor:[UIColor clearColor] tag:SJVideoPlayControlViewTag_Replay target:self sel:@selector(clickedBtn:) fontSize:16];
    _replayBtn.titleLabel.numberOfLines = 3;
    _replayBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    NSAttributedString *attr = [NSAttributedString mh_imageTextWithImage:[UIImage imageNamed:@"sj_video_player_replay"] imageW:35 imageH:35 title:@"重播" fontSize:16 titleColor:[UIColor whiteColor] spacing:6];
    [_replayBtn setAttributedTitle:attr forState:UIControlStateNormal];
    return _replayBtn;
}

- (UIView *)lockBtnContainerView {
    if ( _lockBtnContainerView ) return _lockBtnContainerView;
    _lockBtnContainerView = [UIView new];
    _lockBtnContainerView.backgroundColor = [UIColor clearColor];
    return _lockBtnContainerView;
}

- (UIButton *)unlockBtn {
    if ( _unlockBtn ) return _unlockBtn;
    _unlockBtn = [UIButton buttonWithImageName:@"sj_video_player_unlock" tag:SJVideoPlayControlViewTag_Unlock target:self sel:@selector(clickedBtn:)];
    return _unlockBtn;
}

- (UIButton *)lockBtn {
    if ( _lockBtn ) return _lockBtn;
    _lockBtn = [UIButton buttonWithImageName:@"sj_video_player_lock" tag:SJVideoPlayControlViewTag_Lock target:self sel:@selector(clickedBtn:)];
    return _lockBtn;
}

// MARK: ...

- (SJMaskView *)bottomContainerView {
    if ( _bottomContainerView ) return _bottomContainerView;
    _bottomContainerView = [SJMaskView new];
    return _bottomContainerView;
}

- (UIButton *)playBtn {
    if ( _playBtn ) return _playBtn;
    _playBtn = [UIButton buttonWithImageName:@"sj_video_player_play" tag:SJVideoPlayControlViewTag_Play target:self sel:@selector(clickedBtn:)];
    return _playBtn;
}

- (UIButton *)pauseBtn {
    if ( _pauseBtn ) return _pauseBtn;
    _pauseBtn = [UIButton buttonWithImageName:@"sj_video_player_pause" tag:SJVideoPlayControlViewTag_Pause target:self sel:@selector(clickedBtn:)];
    return _pauseBtn;
}

- (UIButton *)fullBtn {
    if ( _fullBtn ) return _fullBtn;
    _fullBtn = [UIButton buttonWithImageName:@"sj_video_player_fullscreen" tag:SJVideoPlayControlViewTag_Full target:self sel:@selector(clickedBtn:)]; 
    return _fullBtn;
}

- (UILabel *)currentTimeLabel {
    if ( _currentTimeLabel ) return _currentTimeLabel;
    _currentTimeLabel = [UILabel labelWithFontSize:12 textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter];
    _currentTimeLabel.text = @"00:00";
    return _currentTimeLabel;
}

- (UILabel *)separateLabel {
    if ( _separateLabel ) return _separateLabel;
    _separateLabel = [UILabel labelWithFontSize:12 textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter];
    _separateLabel.text = @"/";
    return _separateLabel;
}

- (UILabel *)durationTimeLabel {
    if ( _durationTimeLabel ) return _durationTimeLabel;
    _durationTimeLabel = [UILabel labelWithFontSize:12 textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter];
    _durationTimeLabel.text = @"00:00";
    return _durationTimeLabel;
}

- (SJSlider *)sliderControl {
    if ( _sliderControl ) return _sliderControl;
    _sliderControl = [SJSlider new];
    _sliderControl.trackHeight = 2;
    _sliderControl.enableBufferProgress = YES;
    _sliderControl.borderColor = [UIColor clearColor];
    _sliderControl.trackImageView.backgroundColor = [UIColor grayColor];
    _sliderControl.bufferProgressColor = [UIColor whiteColor];
    return _sliderControl;
}

- (SJSlider *)draggingProgressView {
    if ( _draggingProgressView ) return _draggingProgressView;
    _draggingProgressView = [SJSlider new];
    _draggingProgressView.trackHeight = 3;
    _draggingProgressView.trackImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    _draggingProgressView.pan.enabled = NO;
    return _draggingProgressView;
}

- (UILabel *)draggingTimeLabel {
    if ( _draggingTimeLabel ) return _draggingTimeLabel;
    _draggingTimeLabel = [UILabel labelWithFontSize:60 textColor:[UIColor colorWithWhite:1 alpha:0.5] alignment:NSTextAlignmentCenter];
    return _draggingTimeLabel;
}


// MARK: ...
- (UIButton *)loadFailedBtn {
    if ( _loadFailedBtn ) return _loadFailedBtn;
    _loadFailedBtn = [UIButton buttonWithTitle:@"加载失败,点击重试" backgroundColor:[UIColor clearColor] tag:SJVideoPlayControlViewTag_LoadFailed target:self sel:@selector(clickedBtn:) fontSize:14];
    return _loadFailedBtn;
}


// MARK: ...

- (SJSlider *)bottomProgressView {
    if ( _bottomProgressView  ) return _bottomProgressView;
    _bottomProgressView = [SJSlider new];
    _bottomProgressView.alpha = 0.001;
    _bottomProgressView.trackImageView.backgroundColor = [UIColor clearColor];
    _bottomProgressView.borderColor = [UIColor clearColor];
    _bottomProgressView.traceImageView.backgroundColor = [UIColor whiteColor];
    _bottomProgressView.trackHeight = 1;
    _bottomProgressView.pan.enabled = NO;
    return _bottomProgressView;
}


// MARK: Lazy

- (NSTimer *)pointTimer {
    if ( _pointTimer ) return _pointTimer;
    __weak typeof(self) _self = self;
    _pointTimer = [NSTimer sj_scheduledTimerWithTimeInterval:1 exeBlock:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( !self.sliderControl.isDragging ) self.hiddenControlPoint += 1;
        else self.hiddenControlPoint = 0;
    } repeats:YES];
    return _pointTimer;
}

@end





@implementation SJVideoPlayerControlView (HiddenOrShow)

/*!
 *  default is NO
 */
- (void)setHiddenPlayBtn:(BOOL)hiddenPlayBtn {
    if ( hiddenPlayBtn == self.hiddenPlayBtn ) return;
    objc_setAssociatedObject(self, @selector(hiddenPlayBtn), @(hiddenPlayBtn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self hiddenOrShowView:self.playBtn bol:hiddenPlayBtn];
}

- (BOOL)hiddenPlayBtn {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is NO
 */
- (void)setHiddenPauseBtn:(BOOL)hiddenPauseBtn {
    if ( hiddenPauseBtn == self.hiddenPauseBtn ) return;
    objc_setAssociatedObject(self, @selector(hiddenPauseBtn), @(hiddenPauseBtn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self hiddenOrShowView:self.pauseBtn bol:hiddenPauseBtn];
}

- (BOOL)hiddenPauseBtn {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is NO
 */
- (void)setHiddenReplayBtn:(BOOL)hiddenReplayBtn {
    if ( hiddenReplayBtn == self.hiddenReplayBtn ) return;
    objc_setAssociatedObject(self, @selector(hiddenReplayBtn), @(hiddenReplayBtn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self hiddenOrShowView:self.replayBtn bol:hiddenReplayBtn];
}

- (BOOL)hiddenReplayBtn {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is NO
 */
- (void)setHiddenPreviewBtn:(BOOL)hiddenPreviewBtn {
    if ( hiddenPreviewBtn == self.hiddenPreviewBtn ) return;
    objc_setAssociatedObject(self, @selector(hiddenPreviewBtn), @(hiddenPreviewBtn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self hiddenOrShowView:self.previewBtn bol:hiddenPreviewBtn];
    if ( hiddenPreviewBtn ) [self hiddenOrShowView:self.previewImgColView bol:hiddenPreviewBtn];
}

- (BOOL)hiddenPreviewBtn {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is NO
 */
- (void)setHiddenLockBtn:(BOOL)hiddenLockBtn {
    if ( hiddenLockBtn == self.hiddenLockBtn ) return;
    objc_setAssociatedObject(self, @selector(hiddenLockBtn), @(hiddenLockBtn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self hiddenOrShowView:self.lockBtn bol:hiddenLockBtn];

}

- (BOOL)hiddenLockBtn {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is NO
 */
- (void)setHiddenLockContainerView:(BOOL)hiddenLockContainerView {
    if ( hiddenLockContainerView == self.hiddenLockContainerView ) return;
    objc_setAssociatedObject(self, @selector(hiddenLockContainerView), @(hiddenLockContainerView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGFloat alpha = 1;
    if ( hiddenLockContainerView ) {
        transform = CGAffineTransformMakeTranslation(-100, 0);
        alpha = 0.001;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.lockBtnContainerView.transform = transform;
        self.lockBtnContainerView.alpha = alpha;
    }];
}

- (BOOL)hiddenLockContainerView {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is NO
 */
- (void)setHiddenControl:(BOOL)hiddenControl {
    if ( hiddenControl == self.hiddenControl ) return;
    objc_setAssociatedObject(self, @selector(hiddenControl), @(hiddenControl), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.isHiddenControl = hiddenControl;
}

- (BOOL)hiddenControl {
   return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is NO
 */
- (void)setHiddenLoadFailedBtn:(BOOL)hiddenLoadFailedBtn {
    if ( hiddenLoadFailedBtn == self.hiddenLoadFailedBtn ) return;
    objc_setAssociatedObject(self, @selector(hiddenLoadFailedBtn), @(hiddenLoadFailedBtn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self hiddenOrShowView:self.loadFailedBtn bol:hiddenLoadFailedBtn];
}

- (BOOL)hiddenLoadFailedBtn {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is NO
 */
- (void)setHiddenBottomProgressView:(BOOL)hiddenBottomProgressView {
    if ( hiddenBottomProgressView == self.hiddenBottomProgressView ) return;
    objc_setAssociatedObject(self, @selector(hiddenBottomProgressView), @(hiddenBottomProgressView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self hiddenOrShowView:self.bottomProgressView bol:hiddenBottomProgressView];
}

- (BOOL)hiddenBottomProgressView {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

/*!
 *  default is NO
 */
- (void)setHiddenUnlockBtn:(BOOL)hiddenUnlockBtn {
    if ( hiddenUnlockBtn == self.hiddenUnlockBtn ) return;
    objc_setAssociatedObject(self, @selector(hiddenUnlockBtn), @(hiddenUnlockBtn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self hiddenOrShowView:self.unlockBtn bol:hiddenUnlockBtn];
}

- (BOOL)hiddenUnlockBtn  {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)hiddenOrShowView:(UIView *)view bol:(BOOL)hidden {
    CGFloat alpha = 1.;
    if ( hidden ) alpha = 0.001;
    if ( view.alpha == alpha ) return;
    [UIView animateWithDuration:0.25 animations:^{
        view.alpha = alpha;
    }];
}

@end




@implementation SJVideoPlayerControlView (TimeOperation)

- (NSString *)formatSeconds:(NSInteger)value {
    NSInteger seconds = value % 60;
    NSInteger minutes = value / 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long) minutes, (long) seconds];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    _currentTimeLabel.text = [self formatSeconds:currentTime];
    _durationTimeLabel.text = [self formatSeconds:duration];
    if ( 0 == duration || isnan(duration) ) return;
    _sliderControl.value = currentTime / duration;
    _bottomProgressView.value = _sliderControl.value;
}

@end



@implementation SJMaskView {
    CAGradientLayer *_maskGradientLayer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self initializeGL];
    return self;
}

- (void)initializeGL {
    _maskGradientLayer = [CAGradientLayer layer];
    _maskGradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,
                                  (__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor];
    [self.layer addSublayer:_maskGradientLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _maskGradientLayer.frame = self.bounds;
}

@end



@interface SJVideoPlayPreviewColCell ()
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIButton *backgroundBtn;
@end

@implementation SJVideoPlayPreviewColCell

@synthesize imageView = _imageView;
@synthesize backgroundBtn = _backgroundBtn;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJVideoPlayPreviewColCellSetupUI];
    return self;
}

- (void)setModel:(SJVideoPreviewModel *)model {
    _model = model;
    _imageView.image = model.image;
}

- (void)clickedBtn:(UIButton *)btn {
    if ( ![self.delegate respondsToSelector:@selector(clickedItemOnCell:)] ) return;
    [self.delegate clickedItemOnCell:self];
}

// MARK: UI

- (void)_SJVideoPlayPreviewColCellSetupUI {
    [self.contentView addSubview:self.backgroundBtn];
    [self.contentView addSubview:self.imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    [_backgroundBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (UIImageView *)imageView {
    if ( _imageView ) return _imageView;
    _imageView = [UIImageView imageViewWithImageStr:@"" viewMode:UIViewContentModeScaleAspectFit];
    return _imageView;
}

- (UIButton *)backgroundBtn {
    if ( _backgroundBtn ) return _backgroundBtn;
    _backgroundBtn = [UIButton buttonWithImageName:@"" tag:0 target:self sel:@selector(clickedBtn:)];
    return _backgroundBtn;
}

@end






@implementation SJVideoPlayerControlView (ColDataSourceMethods)

// MARK: UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.previewImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SJVideoPlayPreviewColCellID forIndexPath:indexPath];
    [cell setValue:self.previewImages[indexPath.row] forKey:@"model"];
    [cell setValue:self forKey:@"delegate"];
    return cell;
}

@end




@implementation SJVideoPlayerControlView (PreviewCellDelegateMethods)

- (void)clickedItemOnCell:(SJVideoPlayPreviewColCell *)cell {
    if ( ![self.delegate respondsToSelector:@selector(controlView:selectedPreviewModel:)] ) return;
    SJVideoPreviewModel *model = cell.model;
    [self.delegate controlView:self selectedPreviewModel:model];
}

@end



// MARK: Preview

@interface SJVideoPreviewModel ()

@property (nonatomic, strong, readwrite) UIImage *image;
@property (nonatomic, assign, readwrite) CMTime localTime;

@end

@implementation SJVideoPreviewModel

+ (instancetype)previewModelWithImage:(UIImage *)image localTime:(CMTime)time {
    SJVideoPreviewModel *model = [self new];
    model.image = image;
    model.localTime = time;
    return model;
}

@end


@implementation SJVideoPlayerControlView (Preview)

- (void)setPreviewImages:(NSArray<SJVideoPreviewModel *> *)previewImages {
    objc_setAssociatedObject(self, @selector(previewImages), previewImages, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.previewImgColView reloadData];
}

- (NSArray<SJVideoPreviewModel *> *)previewImages {
    return objc_getAssociatedObject(self, _cmd);
}

@end






// MARK: Observers


@implementation SJVideoPlayerControlView (DBObservers)


- (void)_SJVideoPlayerControlViewObservers {
    [self addObserver:self forKeyPath:@"hiddenControlPoint" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"isHiddenControl" options:NSKeyValueObservingOptionNew context:nil];

}

- (void)_SJVideoPlayerControlViewRemoveObservers {
    [self removeObserver:self forKeyPath:@"hiddenControlPoint"];
    [self removeObserver:self forKeyPath:@"isHiddenControl"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( [keyPath isEqualToString:@"hiddenControlPoint"] ) {
        if ( _hiddenControlPoint >= SJHiddenControlInterval ) { self.hiddenControl = YES;}
    }
    else if ( [keyPath isEqualToString:@"isHiddenControl"] ) {
        if ( self.isHiddenControl )
            [self hiddenController];
        else
            [self showController];
        
        [self previewImgColView_HiddenAnima];
    }
}

@end

