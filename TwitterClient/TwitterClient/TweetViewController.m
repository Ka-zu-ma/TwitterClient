//
//  TweetViewController.m
//  TwitterClient
//
//  Created by 宮崎数磨 on 2016/06/29.
//  Copyright © 2016年 Miyazaki Kazuma. All rights reserved.
//

#import "TweetViewController.h"
#import <TwitterKit/TwitterKit.h>

@interface TweetViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *tweets;

@end

@implementation TweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[TWTRTweetTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [[Twitter sharedInstance] logInWithCompletion:^
     (TWTRSession *session, NSError *error) {
         if (session) {
             NSLog(@"signed in as %@", [session userName]);
             
             [self loadTweetsOfWord:session.userID];
             
         } else {
             NSLog(@"error: %@", [error localizedDescription]);
         }
     }];
    
    self.navigationItem.title = _wordString;
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//あるワードを含むツイートを取得
-(void)loadTweetsOfWord:(NSString *)userId{
    
    //リツイートを除く
    NSString *excludeRetweets = @" exclude:retweets";
    
    _wordString = [_wordString stringByAppendingString:excludeRetweets];
    
    NSString *endpoint = @"https://api.twitter.com/1.1/search/tweets.json";
    
    NSDictionary *parameters = @{@"q":_wordString,@"count":@"20"};
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
