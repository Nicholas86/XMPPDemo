//
//  RosterTableViewController.m
//  LessonXMPP
//
//  Created by lanouhn on 15/9/14.
//  Copyright (c) 2015年 LiYang. All rights reserved.
//

#import "RosterTableViewController.h"
#import "XMPPHlper.h"
#import "chatTableViewController.h"
@interface RosterTableViewController ()<XMPPRosterDelegate>
@property (nonatomic, strong) NSMutableArray *listArr;
@end

@implementation RosterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [XMPPHlper shareXMPPHelper].stream.myJID.user;
    self.listArr = [NSMutableArray array];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"deque"];
    //添加代理,实现添加好友后的方法回调
    [[XMPPHlper shareXMPPHelper].xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deque" forIndexPath:indexPath];
    cell.textLabel.text = ((XMPPJID *)self.listArr[indexPath.row]).user;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    chatTableViewController *chatVC = [[chatTableViewController alloc] init];
    chatVC.jid = self.listArr[indexPath.row];
    [self.navigationController pushViewController:chatVC animated:YES];
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
#pragma mark - XMPPRosterDelegate

- (void)xmppRoster:(XMPPRoster *)sender didRecieveRosterItem:(NSXMLElement *)item {
    NSLog(@"%@", item);
    NSString *jidStr = [[item attributeForName:@"jid"] stringValue];
    NSString *subscriptionStatus = [[item attributeForName:@"subscription"] stringValue];
    if ([subscriptionStatus isEqualToString:@"both"]) {
        XMPPJID *jid = [XMPPJID jidWithString:jidStr resource:kResource];
        if ([self.listArr containsObject:jid]) {
            return;
        }
        [self.listArr addObject:jid];
    }
    [self.tableView reloadData];
    
}
@end
