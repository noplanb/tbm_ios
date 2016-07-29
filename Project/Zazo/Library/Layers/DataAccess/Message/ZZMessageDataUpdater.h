//
//  ZZMessageDataUpdater.h
//  Zazo
//
//  Created by Server on 28/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZMessageDomainModel.h"

@interface ZZMessageDataUpdater : NSObject

+ (void)insertMessage:(ZZMessageDomainModel *)message; 

//+ (void)updateMessageWithID:(NSString *)messageID setBody:(NSString *)body;
//+ (void)updateMessageWithID:(NSString *)messageID setMessageID:(NSString *)messageID;
//+ (void)updateMessageWithID:(NSString *)messageID setFriendID:(NSString *)friendID;

@end
