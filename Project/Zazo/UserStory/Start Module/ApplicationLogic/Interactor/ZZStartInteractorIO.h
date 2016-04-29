//
//  ZZStartInteractorIO.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZApplicationVersionEnumHelper.h"

@protocol ZZStartInteractorInput <NSObject>

- (void)checkVersionStateAndSession;

@end


@protocol ZZStartInteractorOutput <NSObject>

- (void)userRequiresAuthentication;
- (void)applicationIsUpToDateAndUserLogged:(BOOL)isUserLoggedIn;
- (void)presentNetworkTestController;

@end