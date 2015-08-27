//
//  ZZDebugStateCellViewModel.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 8/27/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@class ZZDebugStateItemDomainModel;

@interface ZZDebugStateCellViewModel : NSObject

+ (instancetype)viewModelWithItem:(ZZDebugStateItemDomainModel*)item;

- (NSString*)title;

@end
