//
//  ZZMessageDataProvider.h
//  Zazo
//
//  Created by Server on 28/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZMessageDomainModel.h"

@interface ZZMessageDataProvider : NSObject

+ (ZZMessageDomainModel *)modelWithID:(NSString *)messageID; // nil if no message

+ (BOOL)messageExists:(NSString *)messageID;

+ (NSArray <ZZMessageDomainModel *> *)messagesOfFriendWithID:(NSString *)friendID;

@end
