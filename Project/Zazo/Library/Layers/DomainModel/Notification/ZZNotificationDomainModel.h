//
//  ZZNotificationDomainModel.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZNotificationsConstants.h"
#import "ZZBaseDomainModel.h"


extern const struct ZZNotificationDomainModelAttributes {
    __unsafe_unretained NSString *type;
    __unsafe_unretained NSString *typeValue;
    __unsafe_unretained NSString *videoID;
    __unsafe_unretained NSString *fromUserMKey;
    __unsafe_unretained NSString *toUserMKey;
    __unsafe_unretained NSString *status;
} ZZNotificationDomainModelAttributes;

@class FEMObjectMapping;

@interface ZZNotificationDomainModel : ZZBaseDomainModel

@property (nonatomic, copy) NSString* type;
@property (nonatomic, assign) ZZNotificationType typeValue;

@property (nonatomic, copy) NSString* videoID;
@property (nonatomic, copy) NSString* fromUserMKey;

@property (nonatomic, copy) NSString* status;
@property (nonatomic, copy) NSString* toUserMKey;

+ (FEMObjectMapping*)mapping;

@end
