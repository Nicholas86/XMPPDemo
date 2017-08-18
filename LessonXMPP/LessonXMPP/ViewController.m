//
//  ViewController.m
//  LessonXMPP
//
//  Created by lanouhn on 15/9/11.
//  Copyright (c) 2015年 LiYang. All rights reserved.
//

#import "ViewController.h"
#import "XMPPHlper.h"
#import "RosterTableViewController.h"
@interface ViewController ()<XMPPStreamDelegate>

@end

@implementation ViewController
- (IBAction)loginAction:(id)sender {
    [[XMPPHlper shareXMPPHelper] loginWith:self.userName.text password:self.passWord.text];
    
}
- (IBAction)registerAction:(id)sender {
     [[XMPPHlper shareXMPPHelper] regisWith:self.userName.text password:self.passWord.text];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //添加通道的代理,方便得到成功注册的方法回调
    [[XMPPHlper shareXMPPHelper].stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //判断是否有账号存储
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //账号
    NSString *userStr = [userDefaults objectForKey:@"username"];
    //密码
    NSString *password = [userDefaults objectForKey:@"password"];
    if (userStr != nil) {
        self.userName.text = userStr;
        self.passWord.text = password;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//验证成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    //进行赋值
    [[NSUserDefaults standardUserDefaults] setObject:self.userName.text forKey:@"username"];
    //密码
    [[NSUserDefaults standardUserDefaults] setObject:self.passWord.text forKey:@"password"];
    //及时存储
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //创建一个好友列表页面
    RosterTableViewController *rostVC = [[RosterTableViewController alloc] init];
    [self.navigationController pushViewController:rostVC animated:YES];
    
}
@end
