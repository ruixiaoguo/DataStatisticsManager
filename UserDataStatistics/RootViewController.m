//
//  RootViewController.m
//  UserDataStatistics
//
//  Created by GRX on 2022/9/23.
//

#import "RootViewController.h"
#import "GGDataStatistics.h"
#import "GrxUserDataManager.h"
#import <OpinionzAlertView/OpinionzAlertView.h>
@interface RootViewController ()

@end

@implementation RootViewController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    GGDataStatistics *data = [GGDataStatistics sharedInstance:@"Grx"];
//    NSString *content = [NSString stringWithFormat:@"\n使用天数\nappUseDays=%zi\n连续使用天数\nappContinuousUseDays=%zi\n使用总时长\nappUseTime=%zi\n启动次数\nappActivateCount=%zi\n上次使用时间:lasttime=%zi", data.appUseDays, data.appContinuousUseDays, data.appUseTime, data.appActivateCount,data.appLastUseTime];
//    NSLog(@"%@",content);
//    [self showAlert:content];
    GrxUserDataManager *data = [GrxUserDataManager sharedInstance:@"Grx"];
    NSString *content = [NSString stringWithFormat:@"\n使用天数\nappUseDays=%zi\n连续使用天数\nappContinuousUseDays=%zi\n使用总时长\nappUseTime=%zi\n启动次数\nappActivateCount=%zi\n上次使用时间:lasttime=%zi", data.appUseDays, data.appContinuousUseDays, data.appUseTime, data.appActivateCount,data.appLastUseTime];
    NSLog(@"%@",content);
    [self showAlert:content];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

-(void)showAlert:(NSString *)content{
    OpinionzAlertView *alert = [[OpinionzAlertView alloc] initWithTitle:@"Info"
                                                                message:content
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
    alert.iconType = OpinionzAlertIconInfo;
    [alert show];
}

@end
