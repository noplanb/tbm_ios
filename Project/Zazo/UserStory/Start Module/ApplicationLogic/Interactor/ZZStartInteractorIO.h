//
//  ZZStartInteractorIO.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@protocol ZZStartInteractorInput <NSObject>

- (void)checkVersion;

@end


@protocol ZZStartInteractorOutput <NSObject>

- (void)userRequiresAuthentication;
- (void)userHasAuthentication;

@end