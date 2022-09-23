//
//  YZDataStatistics.m
//  YZDataStatistics
//
//  Created by WangYunzhen on 15/9/29.
//  Copyright © 2015年 Wang Yunzhen. All rights reserved.
//

#import "GGDataStatistics.h"
#import "KeyChainStore.h"
#import <UIKit/UIKit.h>

static NSString * const GGZAppUseDays              = @"GGAppUseDays";
static NSString * const GGAppContinuousUseDays     = @"GGAppContinuousUseDays";
static NSString * const GGAppUseTime               = @"GGAppUseTime";
static NSString * const GGAppActivateCount         = @"GGAppActivateCount";
static NSString * const GGAppLastEnterDate         = @"GGAppLastEnterDate";
static NSString * const GGAppLastExitDate          = @"GGAppLastExitDate";

@interface GGDataStatistics ()

@property (nonatomic, assign) NSInteger         appUseDays;             // 使用app的天数
@property (nonatomic, assign) NSInteger         appContinuousUseDays;   // 连续使用app的天数
@property (nonatomic, assign) NSInteger         appUseTime;             // app的使用时间，单位秒
@property (nonatomic, assign) NSInteger         appActivateCount;       // app打开的次数

@property (nonatomic, strong) NSDate            *appLastEnterDate;      // 上次打开app的时间
@property (nonatomic, strong) NSDate            *appLastExitDate;       // 上次退出app的时间

@property (nonatomic, strong) NSDate            *appEnterDate;          // 本次app打开的时间
@property (nonatomic, strong) NSDate            *appExitDate;           // 本次app退出的时间
@property (nonatomic, strong) NSString    *userId;    //用户ID

@end

@implementation GGDataStatistics

#pragma mark - 初始化
+ (instancetype)sharedInstance:(NSString *)userId
{
    static GGDataStatistics *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[GGDataStatistics alloc] initWithUserId:userId];
    });
    return instance;
}

- (instancetype)initWithUserId:(NSString *)userId
{
    if (self = [super init]) {
        self.userId = userId;
        self.appUseDays = [[KeyChainStore load:[NSString stringWithFormat:@"%@_%@",GGZAppUseDays,userId]] integerValue];
        self.appContinuousUseDays = [[KeyChainStore load:[NSString stringWithFormat:@"%@_%@",GGAppContinuousUseDays,userId]] integerValue];
        self.appUseTime = [[KeyChainStore load:[NSString stringWithFormat:@"%@_%@",GGAppUseTime,userId]] integerValue];
        self.appLastEnterDate = [KeyChainStore load:[NSString stringWithFormat:@"%@_%@",GGAppLastEnterDate,userId]];
        self.appLastExitDate = [KeyChainStore load:[NSString stringWithFormat:@"%@_%@",GGAppLastExitDate,userId]];
        self.appActivateCount = [[KeyChainStore load:[NSString stringWithFormat:@"%@_%@",GGAppActivateCount,userId]] integerValue];
        if (self.appUseDays <= 0) {
            self.appUseDays = 1;
        }
        if (self.appContinuousUseDays <= 0) {
            self.appContinuousUseDays = 1;
        }
        if (self.appActivateCount <= 0) {
            self.appActivateCount = 1;
        }
        if (self.appLastEnterDate == nil) {
            self.appLastEnterDate = [NSDate date];
        }
        if (self.appLastExitDate == nil) {
            self.appLastExitDate = [NSDate date];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onAppEnterForeground)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onAppEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}

#pragma mark - observer callback
- (void)onAppEnterForeground
{
    self.appEnterDate = [NSDate date]; // 本次打开app的时间
    NSTimeInterval timeOnce = 0;
    if ([self.appEnterDate earlierDate:self.appLastExitDate] == self.appLastExitDate) {
        timeOnce = [self.appEnterDate timeIntervalSinceDate:self.appLastExitDate];
    } else {
        self.appLastExitDate = self.appEnterDate;
    }
    self.appActivateCount++;// 使用次数+1
    NSInteger days = [self daysFromDate:self.appLastExitDate toDate:self.appEnterDate];
    if (days >= 1) { // 如果不是同一日期，则表示是不同的天数
        self.appUseDays++;
        if (days > 1) {
            self.appContinuousUseDays = 1; // 间隔超过一天，则连续天数置为0
        } else {
            self.appContinuousUseDays++; // 如果间隔一天，表示连续两天在使用
        }
    }
    [KeyChainStore save:[NSString stringWithFormat:@"%@_%@",GGZAppUseDays,self.userId] data:[NSString stringWithFormat:@"%ld",(long)self.appUseDays]];
    [KeyChainStore save:[NSString stringWithFormat:@"%@_%@",GGAppContinuousUseDays,self.userId] data:[NSString stringWithFormat:@"%ld",(long)self.appContinuousUseDays]];
    [KeyChainStore save:[NSString stringWithFormat:@"%@_%@",GGAppActivateCount,self.userId] data:[NSString stringWithFormat:@"%ld",(long)self.appActivateCount]];
}

- (void)onAppEnterBackground
{
    self.appExitDate = [NSDate date];
    if ([self.appExitDate earlierDate:self.appEnterDate] == self.appEnterDate) {
        self.appUseTime += [self.appExitDate timeIntervalSinceDate:self.appEnterDate];
    }
    self.appLastEnterDate = self.appEnterDate;
    self.appLastExitDate = self.appExitDate;
    NSLog(@"22222====%ld",(long)self.appUseTime);
    [KeyChainStore save:[NSString stringWithFormat:@"%@_%@",GGAppUseTime,self.userId] data:[NSString stringWithFormat:@"%ld",(long)self.appUseTime]];
    self.appUseTime = [[KeyChainStore load:[NSString stringWithFormat:@"%@_%@",GGAppUseTime,self.userId]] integerValue];
    NSLog(@"33333====%ld",(long)self.appUseTime);
    [KeyChainStore save:[NSString stringWithFormat:@"%@_%@",GGAppLastEnterDate,self.userId] data:self.appLastEnterDate];
    [KeyChainStore save:[NSString stringWithFormat:@"%@_%@",GGAppLastExitDate,self.userId] data:self.appLastExitDate];
}

#pragma mark - calculate date
- (NSInteger)daysFromDate:(NSDate *)startDate toDate:(NSDate *)endDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_8_0
    NSCalendarUnit units = NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
#else
    NSCalendarUnit units = NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
#endif
    
    NSDateComponents *comp1 = [calendar components:units fromDate:startDate];
    NSDateComponents *comp2 = [calendar components:units fromDate:endDate];
    
    [comp1 setHour:0];
    [comp2 setHour:0];
    
    NSDate *date1 = [calendar dateFromComponents:comp1];
    NSDate *date2 = [calendar dateFromComponents:comp2];

#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_8_0
    return [[calendar components:NSCalendarUnitDay fromDate:date1 toDate:date2 options:0] day];
#else
    return [[calendar components:NSDayCalendarUnit fromDate:date1 toDate:date2 options:0] day];
#endif

}

@end

