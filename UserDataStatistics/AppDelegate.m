//
//  AppDelegate.m
//  UserDataStatistics
//
//  Created by GRX on 2022/9/23.
//

#import "AppDelegate.h"
#import "RootViewController.h""
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    RootViewController *rootVC = [[RootViewController alloc]init];
    self.window.rootViewController = rootVC;
    return YES;
}


@end
