//
//  ZZNotificationDomainModel.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZNotificationsConstants.h"
#import "ZZBaseDomainModel.h"

@class FEMObjectMapping;

@interface ZZNotificationDomainModel : ZZBaseDomainModel

@property (nonatomic, copy) NSString* type;
@property (nonatomic, assign) ZZNotificationType typeValue;

@property (nonatomic, copy) NSString* videoID;
@property (nonatomic, copy) NSString* fromUserMKey;
@property (nonatomic, copy) NSString* toUserMKey;

+ (FEMObjectMapping*)mapping;

@end
