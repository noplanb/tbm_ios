//
//  ZZMessageDomainModel.h
//  Zazo
//
//  Created by Server on 28/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZBaseDomainModel.h"

typedef NS_ENUM(NSUInteger, ZZMessageType) {
    ZZMessageTypeText,
    ZZMessageTypeTranscript
};

@interface ZZMessageDomainModel : ZZBaseDomainModel

@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *messageID;
@property (nonatomic, strong) NSString *friendID;

@property (nonatomic, assign) ZZMessageType type;

@end