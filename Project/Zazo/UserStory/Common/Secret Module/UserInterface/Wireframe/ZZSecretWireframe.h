//
//  ZZSecretWireframe.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ZZSecretWireframe : NSObject

- (void)presentSecretControllerFromNavigationController:(UINavigationController *)nc;

- (void)presentLogsController;

- (void)presentStateController;

- (void)presentDebugController;

- (void)presentOrDismissSecretControllerFromNavigationController:(UINavigationController *)nc;
@end
