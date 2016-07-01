//
//  HomeViewController.m
//  TwitterClient
//
//  Created by 宮崎数磨 on 2016/06/27.
//  Copyright © 2016年 Miyazaki Kazuma. All rights reserved.
//

#import "HomeViewController.h"
#import <TwitterKit/TwitterKit.h>
#import "WordDB.h"

@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) TWTRLogInButton *logInButton;
@property(nonatomic) UIRefreshControl *refreshControl;

@property(nonatomic) TWTRSession *session;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *tweets;

@property (strong,nonatomic) NSString *userID;
@end

@implementation HomeViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [_tableView registerClass:[TWTRTweetTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    _tableView.hidden = YES;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    // Refresh Control のインスタンス化
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    // ユーザーが Pull to refresh したときのハンドラを設定
    [refreshControl addTarget:self
                       action:@selector(refreshControlStateChanged)
             forControlEvents:UIControlEventValueChanged];
    // TableViewに追加
    [_tableView addSubview:refreshControl];
    self.refreshControl = refreshControl;
    
    //ログインボタン
    TWTRLogInButton *logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession *session, NSError *error) {
        if (error) {
            NSLog(@"Error : %@", error);
        } else {
            
            _logInButton.hidden = YES;
            _tableView.hidden = NO;
            
            _session = session;
            
            
            [self loadTweetsOfWords:session.userID];

            NSLog(@"UserName : %@", session.userName);
        }
    }];
    
    logInButton.center = self.view.center;
    _logInButton = logInButton;
    [self.view addSubview:logInButton];
    
    
    

    // Do any additional setup after loading the view from its nib.
}

//-(void)viewWillAppear:(BOOL)animated{
//    
//    [[Twitter sharedInstance] logInWithCompletion:^
//     (TWTRSession *session, NSError *error) {
//         if (session) {
//             NSLog(@"signed in as %@", [session userName]);
//             
//             
//         } else {
//             NSLog(@"error: %@", [error localizedDescription]);
//         }
//     }];
//}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//あるワードを含むツイートを取得
-(void)loadTweetsOfWords:(NSString *)userId{
    
    //DBから特定ワードを全て取得
    NSMutableArray *words = [WordDB selectTable];
    
    NSInteger wordsCount = words.count;
    
    NSString *wordsString = @"";
    
    //OR検索
    NSString *orString = @" OR ";
    
    for (int i = 0; i <= wordsCount - 1; i++) {
        
        wordsString = [wordsString stringByAppendingString:words[i]];
        
        if (i != wordsCount - 1) {
            wordsString = [wordsString stringByAppendingString:orString];
        }
    }
    
//NSLog(@"wordString:%@",wordsString);
    
    if (wordsString.length == 0) {
        return;
    }
    
    //リツイートを除く
    NSString *excludeRetweets = @" exclude:retweets";
    
    wordsString = [wordsString stringByAppendingString:excludeRetweets];
    
    NSString *endpoint = @"https://api.twitter.com/1.1/search/tweets.json";
    
    NSDictionary *parameters = @{@"q":wordsString,@"count":@"20"};
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
                        
                        NSLog(@"maxidは、%@",jsonData[@"statuses"][@"max_id"]);
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
        
        [self loadTweetsOfWords:_session.userID];

        
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
    
    
    if (_tweets.count > indexPath.row) {
        
        [cell configureWithTweet:_tweets[indexPath.row]];
//        cell.tweetView.delegate = self;
        
//        if ((_tweets.count - 1) == indexPath.row && self.maxIdStr != "") {
        
            [self loadTweetsOfWords:_session.userID];

//        }
        
    }
    
    return cell;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [TWTRTweetTableViewCell heightForTweet:_tweets[indexPath.row] style:TWTRTweetViewStyleCompact width:_tableView.bounds.size.width showingActions:true];
    
}

@end
