//
//  YZDataStatistics.h
//  YZDataStatistics
//
//  统计App启动的次数和使用天数，连续使用天数，使用的时长等信息
//  集成方法也很简单，在application:didFinishLaunchingWithOptions:这个方法里面调用
//  [YZDataStatistics sharedInstance]即可
//
//  Created by WangYunzhen on 15/9/29.
//  Copyright © 2015年 Wang Yunzhen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GGDataStatistics : NSObject

@property (nonatomic, assign) NSInteger   appUseDays;             // 使用app的天数
@property (nonatomic, assign) NSInteger   appContinuousUseDays;   // 连续使用app的天数
@property (nonatomic, assign) NSInteger   appUseTime;             // app的使用时间，单位秒
@property (nonatomic, assign) NSInteger   appActivateCount;       // app打开的次数

@property (nonatomic, strong) NSDate      *appLastEnterDate;      // 上次打开app的时间
@property (nonatomic, strong) NSDate      *appLastExitDate;       // 上次退出app的时间

@property (nonatomic, strong) NSString    *userId;    //用户ID

#pragma mark - 初始化
+ (instancetype)sharedInstance:(NSString *)userId;

@end
