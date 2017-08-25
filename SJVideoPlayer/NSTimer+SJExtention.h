//
//  NSTimer+SJExtention.h
//  SJVideoPlayerProject
//
//  Created by HarrisDeng on 2017/8/18.
//  Copyright © 2017年 harris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (SJExtention)

+ (instancetype)sj_scheduledTimerWithTimeInterval:(NSTimeInterval)ti exeBlock:(void(^)())block repeats:(BOOL)yesOrNo;

@end
