//
//  AppDelegate.m
//  IMSDK-OC
//
//  Created by HCF on 15/12/1.
//  Copyright © 2015年 HCF. All rights reserved.
//

#import "AppDelegate.h"
#import "QMProfileManager.h"
#import "QMHomeViewController.h"

#import <UserNotifications/UserNotifications.h>
#import <QMChatSDK/QMChatSDK.h>
#import <QMChatSDK/QMChatSDK-Swift.h>
#import "QMManager.h"

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self registerUserNotification];

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    QMHomeViewController *vc = [[QMHomeViewController alloc]init];
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nv;
    
    [self.window makeKeyAndVisible];
    
    /**
     创建文件管理类
     name: 可随便填写
     password: 可随便填写
     */
    QMProfileManager *manger = [QMProfileManager sharedInstance];
    [manger loadProfile:@"moor" password:@"123456"];
        
    if (@available(iOS 11.0, *)){
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    
    return YES;
}

- (void)registerUserNotification {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"request authorization succeeded!");
            }
        }];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }
    
}

// 远程通知注册成功委托
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"注册deviceToken");
    [QMConnect setServerToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"\n>>>[DeviceToken Error]:%@\n\n", error.description);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@" userinfo ===== %@", userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSString *messageAlert = [[userInfo objectForKey:@"aps"]objectForKey:@"alert"];
    
    if (application.applicationState == UIApplicationStateActive) {
        [application setApplicationIconBadgeNumber:0];
        //弹框通知
        UIAlertController * stateAlert = [UIAlertController alertControllerWithTitle:@"客服新消息" message:messageAlert preferredStyle:UIAlertControllerStyleAlert];
        [stateAlert addAction:[UIAlertAction actionWithTitle:@"前往" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [QMConnect registerSDKWithAppKey:@"" userName:@"" userId:@""];
        }]];
        [stateAlert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
        [self.window.rootViewController presentViewController:stateAlert animated:YES completion:nil];
    }else {
        [QMConnect registerSDKWithAppKey:@"" userName:@"" userId:@""];
    }
    
    [QMManager defaultManager].selectedPush = YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //断开连接
    [QMConnect logout];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
