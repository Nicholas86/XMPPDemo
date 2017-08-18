//
//  XMPPHlper.m
//  LessonXMPP
//
//  Created by lanouhn on 15/9/11.
//  Copyright (c) 2015年 LiYang. All rights reserved.
//

#import "XMPPHlper.h"
#import "XMPPStream.h"

typedef NS_ENUM(NSInteger, IsloginOrRegis) {
    islogin = 0,
    isregis = 1
};

@interface XMPPHlper ()
@property (nonatomic, assign) IsloginOrRegis isloginOrRegis;
//密码
@property (nonatomic, strong) NSString *password;
//好友申请的JID
@property (nonatomic, strong) XMPPJID *jid;
@property (nonatomic, strong) XMPPMessageArchiving *message; //信息归档对象

@end


@implementation XMPPHlper
+ (XMPPHlper *)shareXMPPHelper {
    static XMPPHlper *xmppHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xmppHelper = [[XMPPHlper alloc] init];
    });
    return xmppHelper;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        //创建一个管道对象
        self.stream = [[XMPPStream alloc] init];
        //指定方向
        self.stream.hostName = kHostName;
        //服务器端口
        self.stream.hostPort = kHostPort;
        //添加一个代理
        [self.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        //初始化并配置花名册
        XMPPRosterCoreDataStorage *rosterCoreDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
        self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:rosterCoreDataStorage dispatchQueue:dispatch_get_main_queue()];
        //添加通道
        [self.xmppRoster activate:self.stream];
        //添加代理
        [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        //消息
        //信息归档数据存储对象
        XMPPMessageArchivingCoreDataStorage *store = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        //创建消息归档对象
        self.message = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:store dispatchQueue:dispatch_get_main_queue()];
        //添加通道
        [self.message activate:self.stream];
        //创建数据管理器,方便查询聊天记录
        self.context = store.mainThreadManagedObjectContext;
        
    }
    return self;
}
#pragma mark -- 登陆注册方法
///登陆方法
- (void)loginWith:(NSString *)userName password:(NSString *)password {
    self.isloginOrRegis = islogin;
    self.password = password;
    //创建一个Jid对象,来告诉服务器你这个对象是什么类型
    //domain:域名.相当于服务器中的某个文件夹的名字
    //resource:标识
    XMPPJID *loginJid = [XMPPJID jidWithUser:userName domain:kDomin resource:kResource];
    self.stream.myJID = loginJid;
    //发送请求
    [self connect];

}
///注册方法
- (void)regisWith:(NSString *)userName password:(NSString *)password {
    self.isloginOrRegis = isregis;
    self.password = password;
    XMPPJID *registerid = [XMPPJID jidWithUser:userName domain:kDomin resource:kResource];
    self.stream.myJID = registerid;
    [self connect];
}
//请求方法
- (void)connect {
    if (self.stream.isConnected) {
        //让他下线
        XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
        //告诉服务器,这是一个下线操作
        [self.stream sendElement:presence];
        //终止传输
        [self.stream disconnect];
        
    }
    NSError *error = nil;
    //-1的意思:一直发送
    [self.stream connectWithTimeout:-1 error:&error];
    NSLog(@"%@", error);
}

#pragma mark -- XMPPStreamDelegate
//通道已经连接
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    if (self.isloginOrRegis == islogin) {
        //登陆
        [self.stream authenticateWithPassword:self.password error:nil];
        
    } else {
        //注册
        [self.stream registerWithPassword:self.password error:nil];
        
    }
}
//登陆成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    //让他上线
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    //告诉服务器,这是一个上线操作
    [self.stream sendElement:presence];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"验证成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}
//登陆失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"验证失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}
//注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"注册成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}
//注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"注册失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}
#pragma mark - XMPPRosterDelegate
//有好友申请的时候 就会走该代理方法
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence {
    self.jid =  presence.from;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否添加对方为好友" delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"同意", nil];
    [alertView show];
}

//开始检索
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender {
    NSLog(@"开始检索");
}

//结束检索
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender {
    NSLog(@"结束检索");
}

//添加好友,类似tableView返回cell
- (void)xmppRoster:(XMPPRoster *)sender didRecieveRosterItem:(NSXMLElement *)item {
    
    
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        {
           //拒绝
           [self.xmppRoster rejectPresenceSubscriptionRequestFrom:self.jid];
            
        }
            break;
        default:
        {
            //同意
            [self.xmppRoster acceptPresenceSubscriptionRequestFrom:self.jid andAddToRoster:YES];
            
        }
            break;
    }
}
@end
