//
//  UserDataInfo+CoreDataProperties.h
//  UserDataStatistics
//
//  Created by GRX on 2022/11/14.
//
//

#import "UserDataInfo+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UserDataInfo (CoreDataProperties)

+ (NSFetchRequest<UserDataInfo *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nullable, nonatomic, copy) NSString *appUseDays;
@property (nullable, nonatomic, copy) NSString *appContinuousUseDays;
@property (nullable, nonatomic, copy) NSString *appUseTime;
@property (nullable, nonatomic, copy) NSString *appActivateCount;
@property (nullable, nonatomic, copy) NSDate *appLastEnterDate;
@property (nullable, nonatomic, copy) NSDate *appLastExitDate;
@property (nullable, nonatomic, copy) NSString *userId;

@end

NS_ASSUME_NONNULL_END
