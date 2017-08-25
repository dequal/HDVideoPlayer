//
//  SJVideoPlayer.h
//  SJVideoPlayerProject
//
//  Created by HarrisDeng on 2017/8/18.
//  Copyright © 2017年 harris. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIView;

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayer : NSObject

+ (instancetype)sharedPlayer;

/*!
 *  if you want to play, you need to set it up.
 */
@property (nonatomic, strong, readwrite) NSURL *assetURL;


/*!
 *  Present View. you shuold set it frame (support autoLayout).
 */
@property (nonatomic, strong, readonly) UIView *view;

/*!
 *  Error
 */
@property (nonatomic, strong, readonly) NSError *error;

@end

NS_ASSUME_NONNULL_END
