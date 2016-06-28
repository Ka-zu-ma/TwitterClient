//
//  HomeViewController.m
//  TwitterClient
//
//  Created by 宮崎数磨 on 2016/06/27.
//  Copyright © 2016年 Miyazaki Kazuma. All rights reserved.
//

#import "HomeViewController.h"
#import <TwitterKit/TwitterKit.h>

@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) TWTRLogInButton *logInButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *tweets;


@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_tableView registerClass:[TWTRTweetTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    _tableView.hidden = YES;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    //ログインボタン
    TWTRLogInButton *logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession *session, NSError *error) {
        if (error) {
            NSLog(@"Error : %@", error);
        } else {
            
            _logInButton.hidden = YES;
            _tableView.hidden = NO;
            
            [self loadTweetsOfWord:session.userID];
            
            NSLog(@"UserName : %@", session.userName);
        }
    }];
    
    logInButton.center = self.view.center;
    _logInButton = logInButton;
    [self.view addSubview:logInButton];
    
//    [[Twitter sharedInstance] logInWithCompletion:^
//     (TWTRSession *session, NSError *error) {
//         if (session) {
//             NSLog(@"signed in as %@", [session userName]);
//         } else {
//             NSLog(@"error: %@", [error localizedDescription]);
//         }
//     }];

    
    
    // Do any additional setup after loading the view from its nib.
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//あるワードを含むツイートを取得
-(void)loadTweetsOfWord:(NSString *)userId{
    
    NSString *endpoint = @"https://api.twitter.com/1.1/search/tweets.json";
    NSDictionary *parameters = @{@"q":@"プログラミング",@"count":@"20"};
    NSError *error = nil;
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userId];
    NSURLRequest *request = [client URLRequestWithMethod:@"GET"
                                                     URL:endpoint
                                              parameters:parameters
                                                   error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        return;
    }
    __weak typeof(self) weakSelf = self;
    
    [client sendTwitterRequest:request
                    completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                        if (connectionError) {
                            NSLog(@"Error: %@", error);
                            return;
                        }
                        NSError *jsonError = nil;
                        id jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&jsonError];
                        if (jsonError) {
                            NSLog(@"Error: %@", jsonError);
                            return;
                        }
                        //search/tweets で返ってくるデータには直接各ツイートのデータが入っているのではなく、statusesという階層を挟んでる
                        weakSelf.tweets = [TWTRTweet tweetsWithJSONArray:jsonData[@"statuses"]];
                        [weakSelf.tableView reloadData];
                    }];
    
}



//あるUserIDのタイムラインを取得
-(void)loadTweets:(NSString *)userId{
    
    // タイムラインを取得
    NSString *endpoint = @"https://api.twitter.com/1.1/statuses/home_timeline.json";
    NSDictionary *parameters = @{};
    NSError *error = nil;
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userId];
    NSURLRequest *request = [client URLRequestWithMethod:@"GET"
                                                     URL:endpoint
                                              parameters:parameters
                                                   error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
        return;
    }
    __weak typeof(self) weakSelf = self;
    
    [client sendTwitterRequest:request
                    completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                        if (connectionError) {
                            NSLog(@"Error: %@", error);
                            return;
                        }
                        NSError *jsonError = nil;
                        id jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&jsonError];
                        if (jsonError) {
                            NSLog(@"Error: %@", jsonError);
                            return;
                        }
                        weakSelf.tweets = [TWTRTweet tweetsWithJSONArray:jsonData];
                        [weakSelf.tableView reloadData];
                    }];
    
    
}

#pragma mark - TableView Datasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _tweets.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TWTRTweetTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [cell configureWithTweet:_tweets[indexPath.row]];
    
    return cell;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [TWTRTweetTableViewCell heightForTweet:_tweets[indexPath.row] style:TWTRTweetViewStyleCompact width:_tableView.bounds.size.width showingActions:true];
    
}

@end
