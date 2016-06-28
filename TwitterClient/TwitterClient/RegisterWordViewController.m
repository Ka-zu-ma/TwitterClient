//
//  RegisterWordViewController.m
//  TwitterClient
//
//  Created by 宮崎数磨 on 2016/06/28.
//  Copyright © 2016年 Miyazaki Kazuma. All rights reserved.
//

#import "RegisterWordViewController.h"
#import "WordDB.h"

@interface RegisterWordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *wordTextField;
- (IBAction)tapRegisterButton:(id)sender;

@end

@implementation RegisterWordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"ワード登録";
    
    // 背景をクリックしたら、キーボードを隠す
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSoftKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)closeSoftKeyboard {
    
    [self.view endEditing: YES];
}

- (IBAction)tapRegisterButton:(id)sender {
    
    NSString *wordString = _wordTextField.text;
    
    if (wordString.length != 0) {
        
        [WordDB insertTable:wordString];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        return;

    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告" message:@"入力しないと登録できません。" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
    
    [alertController addAction:action];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
