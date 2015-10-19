//
//  ZZDebugStateCellViewModel.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 8/27/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@class ZZDebugVideoStateDomainModel;

@interface ZZDebugStateCellViewModel : NSObject

+ (instancetype)viewModelWithItem:(ZZDebugVideoStateDomainModel*)item;

- (NSString*)title;
- (NSString*)status;

@end
