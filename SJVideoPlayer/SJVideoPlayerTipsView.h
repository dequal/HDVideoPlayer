//
//  SJVideoPlayerTipsView.h
//  SJVideoPlayerProject
//
//  Created by HarrisDeng on 2017/8/18.
//  Copyright © 2017年 harris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJVideoPlayerTipsView : UIView

@property (nonatomic, strong, readonly) UILabel *titleLabel;

@property (nonatomic, strong, readwrite) UIImage *normalShowImage;

@property (nonatomic, strong, readwrite) UIImage *minShowImage;

@property (nonatomic, strong, readonly) UILabel *minShowTitleLabel;

/*!
 *  value 0 ... 1.0
 */
@property (nonatomic, assign, readwrite) CGFloat value;

@end
