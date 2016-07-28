//
//  ZZMessageNotificationDomainModel.h
//  Zazo
//
//  Created by Server on 28/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZBaseDomainModel.h"

@class FEMObjectMapping;

@interface ZZMessageNotificationDomainModel : ZZBaseDomainModel

@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSString *content_type;
@property (strong, nonatomic) NSString *from_mkey;
@property (strong, nonatomic) NSString *host;
@property (strong, nonatomic) NSString *message_id;
@property (strong, nonatomic) NSString *owner_mkey;
@property (strong, nonatomic) NSString *type;

+ (FEMObjectMapping *)mapping;

@end