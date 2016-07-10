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
#import "CacheDirectory.h"

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
    
//    [CacheDirectory createNewDirectory:@"AllWord"];
    
    [_tableView registerClass:[TWTRTweetTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    _tableView.hidden = YES;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    // Refresh Control のインスタンス化
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    // ユーザーが Pull to refresh したときのハンドラを設定
    [refreshControl addTarget:self
                       action:@selector(reload)
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
            
            //ツイッターログインボタンに表示させるときに隠していたtabbarを表示
            self.tabBarController.tabBar.hidden = NO;
            
            [self loadTweetsOfWords:session.userID];

            NSLog(@"UserName : %@", session.userName);
        }
    }];
    _logInButton = logInButton;
    
    // AutoresizingMaskを使用しない
    //（これはAutoLayoutを使用するときには必須の設定）
    logInButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:logInButton];
    
    //高さ autolayout
    [logInButton addConstraint:[NSLayoutConstraint constraintWithItem:logInButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:100]];
    
    //下
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:logInButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    //左
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:logInButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    //右
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:logInButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    
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
    
    //どういうときにキャッシュから取得してくるか
    
    //キャッシュファイルからデータ取得
//    NSError *jsonError = nil;
//    id jsonData = [NSJSONSerialization JSONObjectWithData:[CacheDirectory getData:nil fileNameString:@"AllWord"]
//                                                  options:NSJSONReadingMutableContainers
//                                                    error:&jsonError];
//    
//    if (jsonError) {
//        NSLog(@"Error: %@", jsonError);
//        return;
//    }
//    
//    _tweets = [TWTRTweet tweetsWithJSONArray:jsonData[@"statuses"]];
//    
//    [_tableView reloadData];
//    
//    return;
    
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
    
    NSDictionary *parameters = @{@"q":wordsString,@"count":@"50"};
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
    
    //ブロックの外で定義された変数をブロック内で使うとき、その変数はブロック内に strong 参照でキャプチャされる。
    //循環参照を引き起こすのを防止
    __weak typeof(self) weakSelf = self;
    
    [client sendTwitterRequest:request
                    completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                        if (connectionError) {
                            
                            NSLog(@"connectionError: %@", connectionError);
                            return;
                        }
                        
                        //一度内容をファイルを別名で書き出し、その後で改名して、その名前のファイルがある場合はそれを上書き
                        [CacheDirectory saveData:data directoryName:nil fileName:@"AllWord"];
                        
                        
                        NSError *jsonError = nil;
                        id jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&jsonError];
                        if (jsonError) {
                            NSLog(@"Error: %@", jsonError);
                            return;
                        }
//                        NSLog(@"json:%@",jsonData);
                        
                        //search/tweets statusesの中のデータをツイート配列に入れる
                        weakSelf.tweets = [TWTRTweet tweetsWithJSONArray:jsonData[@"statuses"]];
                        
                        [weakSelf.tableView reloadData];
                    }];
    
    
    
    
}

-(void)reload{
    
    
    // 3 秒待ってからハンドリングを行う、URL リクエストとレスポンスに似せたダミーコード
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    _tweets = [[NSMutableArray alloc] init];
    
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

    [cell configureWithTweet:_tweets[indexPath.row]];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [TWTRTweetTableViewCell heightForTweet:_tweets[indexPath.row] style:TWTRTweetViewStyleCompact width:_tableView.bounds.size.width showingActions:true];
    
}

@end
