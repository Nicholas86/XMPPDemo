//
//  chatTableViewController.m
//  LessonXMPP
//
//  Created by lanouhn on 15/9/14.
//  Copyright (c) 2015年 LiYang. All rights reserved.
//

#import "chatTableViewController.h"

@interface chatTableViewController ()<XMPPStreamDelegate>
@property (nonatomic, strong) NSMutableArray *messageArr;
@end

@implementation chatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化messageArr
    self.messageArr = [NSMutableArray array];
    self.title = self.jid.user;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(handleAdd:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    //添加代理
    [[XMPPHlper shareXMPPHelper].stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self reloadmessage]; //刷新数据

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//消息添加
- (void)handleAdd:(UIBarButtonItem *)item {
    XMPPMessage *message = [[XMPPMessage alloc] initWithType:@"chat" to:self.jid];
    [message addBody:@"hello, XMPP,你个SB"]; //要发送给对方的文字
    [[XMPPHlper shareXMPPHelper].stream sendElement:message];
}
//消息刷新
- (void)reloadmessage {
    NSManagedObjectContext *context = [XMPPHlper shareXMPPHelper].context;
    //找到对应的表
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    //创建检索体
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entityDescription;
    //检索条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr == %@ and streamBareJidStr == %@", self.jid.bare, [XMPPHlper shareXMPPHelper].stream.myJID.bare];
    fetchRequest.predicate = predicate;
    
    //搜索
    NSArray *tempArr = [context executeFetchRequest:fetchRequest error:nil];
    [self.messageArr removeAllObjects];
    [self.messageArr addObjectsFromArray:tempArr];
    [self.tableView reloadData];
}
#pragma mark - XMPPStreamDelegate
//已经发送
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    [self.messageArr addObject:message];
    [self.tableView reloadData];
    
}
//已经接收
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    [self.messageArr addObject:message];
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *indetifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indetifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indetifier];
    }
    XMPPMessageArchiving_Message_CoreDataObject *message = self.messageArr[indexPath.row];
    cell.textLabel.text = message.body;
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
