//
//  ZZNotificationTransportService.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZFriendDomainModel;
@class ZZUserDomainModel;

@interface ZZNotificationTransportService : NSObject


#pragma mark - Genral APNS

+ (RACSignal *)uploadToken:(NSString *)token userMKey:(NSString *)mkey;


#pragma mark - Outgoing Events

+ (RACSignal *)sendVideoReceivedNotificationTo:(ZZFriendDomainModel *)model
                                   videoItemID:(NSString *)videoItemID
                                          from:(ZZUserDomainModel *)user;

+ (RACSignal *)sendVideoStatusUpdateNotificationTo:(ZZFriendDomainModel *)model
                                       videoItemID:(NSString *)videoItemID
                                            status:(NSString *)status
                                              from:(ZZUserDomainModel *)user;

@end
