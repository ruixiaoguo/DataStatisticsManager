//
//  GrxUserDataManager.m
//  UserDataStatistics
//
//  Created by GRX on 2022/11/14.
//

#import "GrxUserDataManager.h"
#import <UIKit/UIKit.h>

@interface GrxUserDataManager (){
    NSDate *appEnterDate;          // 本次app打开的时间
    NSDate *appExitDate;           // 本次app退出的时间
}
@end
@implementation GrxUserDataManager
#pragma mark - 初始化
+ (instancetype)sharedInstance:(NSString *)userId
{
    static GrxUserDataManager *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[GrxUserDataManager alloc] initWithUserId:userId];
    });
    return instance;
}

- (instancetype)initWithUserId:(NSString *)userId
{
    if (self = [super init]) {
        self.userId = userId;
        UserDataInfo *infoModel = [self searchUserDataInfoFromData];
        self.appUseDays = [infoModel.appUseDays integerValue];
        self.appContinuousUseDays = [infoModel.appContinuousUseDays integerValue];
        self.appUseTime = [infoModel.appUseTime integerValue];
        self.appLastEnterDate = infoModel.appLastEnterDate;
        self.appLastExitDate = infoModel.appLastExitDate;
        self.appActivateCount = [infoModel.appActivateCount integerValue];
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
        self.appLastUseTime = [self.appLastExitDate timeIntervalSinceDate:self.appLastEnterDate];
        
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
    appEnterDate = [NSDate date]; // 本次打开app的时间
    NSTimeInterval timeOnce = 0;
    if ([appEnterDate earlierDate:self.appLastExitDate] == self.appLastExitDate) {
        timeOnce = [appEnterDate timeIntervalSinceDate:self.appLastExitDate];
    } else {
        self.appLastExitDate = appEnterDate;
    }
    self.appActivateCount++;// 使用次数+1
    NSInteger days = [self daysFromDate:self.appLastExitDate toDate:appEnterDate];
    if (days >= 1) { // 如果不是同一日期，则表示是不同的天数
        self.appUseDays++;
        if (days > 1) {
            self.appContinuousUseDays = 1; // 间隔超过一天，则连续天数置为0
        } else {
            self.appContinuousUseDays++; // 如果间隔一天，表示连续两天在使用
        }
    }
    /** 进入前台保存用户统计使用情况 */
    [self addEnterForegroundUserData];
}

- (void)onAppEnterBackground
{
    appExitDate = [NSDate date];
    if ([appExitDate earlierDate:appEnterDate] == appEnterDate) {
        self.appUseTime += [appExitDate timeIntervalSinceDate:appEnterDate];
    }
    self.appLastEnterDate = appEnterDate;
    self.appLastExitDate = appExitDate;
    /** 进入后台保存用户统计使用情况 */
    [self addEnterBackgroundUserData];
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

/** 进入前台保存用户统计使用情况 */
-(void)addEnterForegroundUserData{
    NSArray *allUserData = [UserDataInfo MR_findAll];
    for (UserDataInfo *info in allUserData) {
        if ([info.userId isEqualToString:self.userId]) {
            /** 更新数据状态 */
            info.appUseDays =  [NSString stringWithFormat:@"%ld",(long)self.appUseDays];
            info.appContinuousUseDays =  [NSString stringWithFormat:@"%ld",(long)self.appContinuousUseDays];
            info.appActivateCount = [NSString stringWithFormat:@"%ld",(long)self.appActivateCount];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            return;
        }
    }
    UserDataInfo *info = [UserDataInfo MR_createEntity];
    info.userId =  self.userId;
    info.appUseDays =  [NSString stringWithFormat:@"%ld",(long)self.appUseDays];
    info.appContinuousUseDays =  [NSString stringWithFormat:@"%ld",(long)self.appContinuousUseDays];
    info.appActivateCount = [NSString stringWithFormat:@"%ld",(long)self.appActivateCount];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}
/** 进入后台保存用户统计使用情况 */
-(void)addEnterBackgroundUserData{
    NSArray *allUserData = [UserDataInfo MR_findAll];
    for (UserDataInfo *info in allUserData) {
        if ([info.userId isEqualToString:self.userId]) {
            /** 更新数据状态 */
            info.appUseTime =  [NSString stringWithFormat:@"%ld",(long)self.appUseTime];
            info.appLastEnterDate =  self.appLastEnterDate;
            info.appLastExitDate = self.appLastExitDate;
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            return;
        }
    }
    UserDataInfo *info = [UserDataInfo MR_createEntity];
    info.userId =  self.userId;
    info.appUseTime =  [NSString stringWithFormat:@"%ld",(long)self.appUseTime];
    info.appLastEnterDate =  self.appLastEnterDate;
    info.appLastExitDate = self.appLastExitDate;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}
/** 查询用户状态 */
-(UserDataInfo *)searchUserDataInfoFromData{
    NSPredicate *infoFilter=[NSPredicate predicateWithFormat:@"userId=%@",self.userId];
    NSArray *allUserData = [UserDataInfo MR_findAllWithPredicate:infoFilter];
    UserDataInfo *infoModel;
    if(allUserData.count!=0){
        infoModel = allUserData[0];
    }else{
        infoModel.appUseDays = @"0";
        infoModel.appContinuousUseDays = @"0";
        infoModel.appActivateCount = @"0";
        infoModel.appUseTime = @"0";
        infoModel.appLastEnterDate =[NSDate date];
        infoModel.appLastExitDate = [NSDate date];
    }
    return infoModel;
}

@end
