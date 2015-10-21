//
//  ZZApplicationRootService.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZNotificationsHandler.h"

@interface ZZApplicationRootService : NSObject <ZZNotificationsHandlerDelegate>

- (void)handleBackgroundSessionWithIdentifier:(NSString*)identifier completionHandler:(ANCodeBlock)completionHandler;
- (void)updateBadgeCounter;
- (void)checkApplicationPermissionsAndResources;

- (void)appDidFailToRegiterRemotenotifications;

@end
