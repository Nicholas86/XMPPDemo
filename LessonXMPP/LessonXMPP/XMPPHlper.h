//
//  XMPPHlper.h
//  LessonXMPP
//
//  Created by lanouhn on 15/9/11.
//  Copyright (c) 2015年 LiYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

@interface XMPPHlper : NSObject<XMPPStreamDelegate, XMPPRosterDelegate, UIAlertViewDelegate>
///管道对象
@property (nonatomic, strong) XMPPStream *stream;
///花名册
@property (nonatomic, strong) XMPPRoster *xmppRoster;
//数据管理对象
@property (nonatomic, strong) NSManagedObjectContext *context;
//单例
+ (XMPPHlper *)shareXMPPHelper;
///登陆方法
- (void)loginWith:(NSString *)userName password:(NSString *)password;
///注册方法
- (void)regisWith:(NSString *)userName password:(NSString *)password;
@end
