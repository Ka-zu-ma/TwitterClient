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
@property(nonatomic) UIRefreshControl *refreshControl;

@property(nonatomic) TWTRSession *session;


@property (strong, nonatomic) NSArray *tweets;

@end

@implementation TweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[TWTRTweetTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    // Refresh Control のインスタンス化
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    // ユーザーが Pull to refresh したときのハンドラを設定
    [refreshControl addTarget:self
                       action:@selector(refreshControlStateChanged)
             forControlEvents:UIControlEventValueChanged];
    // TableViewに追加
    [_tableView addSubview:refreshControl];
    self.refreshControl = refreshControl;
    
    //ログイン
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
                            
                            NSLog(@"connectionError: %@", connectionError);
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

-(void)refreshControlStateChanged{
    
    // 3 秒待ってからハンドリングを行う、URL リクエストとレスポンスに似せたダミーコード
    //    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC));
    //    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    // モデルの更新などのレスポンス処理...
    
    [self loadTweetsOfWord:_session.userID];
    
    
    // UI 更新
    //        dispatch_async(dispatch_get_main_queue(), ^{
    
    [self.refreshControl endRefreshing];
    //        });
    //    });
    
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
