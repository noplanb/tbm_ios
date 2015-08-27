//
//  ZZDebugStateCellViewModel.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 8/27/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZDebugStateCellViewModel.h"
#import "ZZDebugStateItemDomainModel.h"
#import "NSObject+ANSafeValues.h"

@interface ZZDebugStateCellViewModel ()

@property (nonatomic, strong) ZZDebugStateItemDomainModel* item;

@end

@implementation ZZDebugStateCellViewModel

+ (instancetype)viewModelWithItem:(ZZDebugStateItemDomainModel*)item
{
    ZZDebugStateCellViewModel* model = [self new];
    model.item = item;
    return model;
}

- (NSString*)title
{
    return [NSObject an_safeString:self.item.itemID];
}

@end
