//
//  ZZSecretScreenModuleInterface.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZPushedSecretScreenTypes.h"

@protocol ZZSecretScreenModuleInterface <NSObject>

- (void)dismissSecretController;
- (void)presentPushedViewControllerWithType:(ZZPushedScreenType)type;

@end
