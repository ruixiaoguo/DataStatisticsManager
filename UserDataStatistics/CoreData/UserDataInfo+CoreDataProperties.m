//
//  UserDataInfo+CoreDataProperties.m
//  UserDataStatistics
//
//  Created by GRX on 2022/11/14.
//
//

#import "UserDataInfo+CoreDataProperties.h"

@implementation UserDataInfo (CoreDataProperties)

+ (NSFetchRequest<UserDataInfo *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"UserDataInfo"];
}

@dynamic appUseDays;
@dynamic appContinuousUseDays;
@dynamic appUseTime;
@dynamic appActivateCount;
@dynamic appLastEnterDate;
@dynamic appLastExitDate;
@dynamic userId;

@end
