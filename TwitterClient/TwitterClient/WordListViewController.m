//
//  WordListViewController.m
//  TwitterClient
//
//  Created by 宮崎数磨 on 2016/06/28.
//  Copyright © 2016年 Miyazaki Kazuma. All rights reserved.
//

#import "WordListViewController.h"
#import "RegisterWordViewController.h"
#import "WordTableViewCell.h"
#import "WordDB.h"
#import "TweetViewController.h"

@interface WordListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *wordListTableView;

@property NSMutableArray *words;

@end

@implementation WordListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _wordListTableView.delegate = self;
    _wordListTableView.dataSource = self;
    
    [_wordListTableView registerNib:[UINib nibWithNibName:@"WordTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];

    self.navigationItem.title = @"マイワード";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didTapAddButton)];
    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    
    [WordDB createTable];
    
    _words = [WordDB selectTable];
    
    
    [_wordListTableView reloadData];
    [super viewWillAppear:animated];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _words.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WordTableViewCell *cell = [_wordListTableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = _words[indexPath.row];
    
    return cell;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //削除ボタン
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        UITableViewCell *cell=[_wordListTableView cellForRowAtIndexPath:indexPath];
        
        [WordDB deleteData:cell.textLabel.text];
        
        [_words removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }];
    
    return @[deleteAction];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TweetViewController *viewController = [[TweetViewController alloc] init];
    
    UITableViewCell *cell=[_wordListTableView cellForRowAtIndexPath:indexPath];
    
    viewController.wordString = cell.textLabel.text;
    
    [self.navigationController pushViewController:viewController animated:YES];
}


-(void)didTapAddButton{
    
    RegisterWordViewController *viewController = [[RegisterWordViewController alloc] init];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
