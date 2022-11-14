//
//  GrxUserDataManager.h
//  UserDataStatistics
//
//  Created by GRX on 2022/11/14.
//

#import <Foundation/Foundation.h>
#import "UserDataInfo+CoreDataClass.h"
#import <MagicalRecord/MagicalRecord.h>
NS_ASSUME_NONNULL_BEGIN

@interface GrxUserDataManager : NSObject
@property (nonatomic, assign) NSInteger   appUseDays;             // 使用app的天数
@property (nonatomic, assign) NSInteger   appContinuousUseDays;   // 连续使用app的天数
@property (nonatomic, assign) NSInteger   appUseTime;             // app的使用时间，单位秒
@property (nonatomic, assign) NSInteger   appActivateCount;       // app打开的次数
@property (nonatomic, strong) NSDate      *appLastEnterDate;      // 上次打开app的时间
@property (nonatomic, strong) NSDate      *appLastExitDate;       // 上次退出app的时间
@property (nonatomic, assign) NSInteger   appLastUseTime;         // 上次使用时间
@property (nonatomic, strong) NSString    *userId;    //用户ID
#pragma mark - 初始化
+ (instancetype)sharedInstance:(NSString *)userId;
@end

NS_ASSUME_NONNULL_END
