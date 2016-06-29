//
//  AppDelegate.m
//  TwitterClient
//
//  Created by 宮崎数磨 on 2016/06/27.
//  Copyright © 2016年 Miyazaki Kazuma. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "WordListViewController.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>

@interface AppDelegate ()<UITabBarControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    HomeViewController *homeViewController = [[HomeViewController alloc] init];
    WordListViewController *wordListViewController = [[WordListViewController alloc] init];
    
    UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:wordListViewController];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    NSArray *viewControllers = @[homeViewController,naviController];
    
    [tabBarController setViewControllers:viewControllers];
    
    tabBarController.delegate = self;
    
    //tabBarControllerの配列を設定したあとで、タイトル設定
    UITabBarItem *tabBarItem1 = [tabBarController.tabBar.items objectAtIndex:0];
    tabBarItem1.title = @"ホーム";
    UITabBarItem *tabBarItem2 = [tabBarController.tabBar.items objectAtIndex:1];
    tabBarItem2.title = @"マイワード";
    
    [self.window setRootViewController:tabBarController];
    [self.window makeKeyAndVisible];
    
    //ナビゲーションバーの色の設定
    //背景カラー
    [UINavigationBar appearance].barTintColor = [UIColor yellowColor];
    //バーアイテムカラー
    [UINavigationBar appearance].tintColor = [UIColor blackColor];
    //タイトルカラー
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor]};

    
    
    //Kitを初期化
    [[Twitter sharedInstance] startWithConsumerKey:@"4CEUZm24hEYGvwEV08eW4npg9" consumerSecret:@"NY0qbFkuCqq5opNBMvLKY4US5fhE2KOi9kdGVReC4jqdfLLjfG"];

    
    [Fabric with:@[[Twitter class]]];

    
    // Override point for customization after application launch.
    return YES;
}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
    
    switch (viewController.view.tag) {
        case 0:
            
//            viewController = [[HomeViewController alloc] init];
//            
//            [viewController :];
            
//            NSLog(@"あああ");
            
            
            break;
            
        case 1:
            
            break;
            
        default:
            break;
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
