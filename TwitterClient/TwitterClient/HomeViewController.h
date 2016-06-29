//
//  HomeViewController.h
//  TwitterClient
//
//  Created by 宮崎数磨 on 2016/06/27.
//  Copyright © 2016年 Miyazaki Kazuma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController
-(void)loadTweetsOfWords:(NSString *)userId;
@end
