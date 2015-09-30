//
//  ZZGridDataUpdater.h
//  Zazo
//
//  Created by ANODA on 9/30/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class ZZGridDomainModel;
@class ZZFriendDomainModel;

@interface ZZGridDataUpdater : NSObject

+ (ZZGridDomainModel*)upsertModel:(ZZGridDomainModel*)model;
+ (ZZGridDomainModel*)updateRelatedUserOnItemID:(NSString*)itemID toValue:(ZZFriendDomainModel*)model;

+ (void)deleteModel:(ZZGridDomainModel*)model;

@end
