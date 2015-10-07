//
//  ZZGridInteractor+ActionHandler.h
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZGridInteractor.h"
#import "ZZGridActionHandlerEnums.h"
#import "ZZGridDomainModel.h"

@interface ZZGridInteractor (ActionHandler)

- (void)_handleModel:(ZZGridDomainModel*)model;

@end
