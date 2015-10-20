//
//  ZZApplicationStateInfoGenerator.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/19/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class ZZDebugSettingsStateDomainModel;

@interface ZZApplicationStateInfoGenerator : NSObject


#pragma mark - Settings

+ (ZZDebugSettingsStateDomainModel*)generateSettingsModel;
+ (NSString*)generateSettingsStateMessage;


#pragma mark - Global 

+ (NSString*)globalStateString;


#pragma mark - Dangling Videos

+ (NSArray*)loadVideoDataWithFriendsModels:(NSArray*)friends;
+ (NSArray*)loadIncomingDandlingItemsFromData:(NSArray*)stateModels;
+ (NSArray*)loadOutgoingDandlingItemsFromData:(NSArray*)stateModels;

@end
