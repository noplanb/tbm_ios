//
//  ZZGridPresenter+ActionHandler.h
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZGridPresenter.h"
#import "ZZGridDomainModel.h"

@interface ZZGridPresenter (ActionHandler)

- (void)_handleEvent:(ZZGridActionEventType)event withDomainModel:(ZZGridDomainModel*)model;
- (void)_handleInviteEvent;
- (void)_handleRecordEventWithCellViewModel:(ZZGridCellViewModel*)cellViewModel;

@end
