//
//  ZZMenuInteractor.m
//  zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZMenuInteractor.h"
#import "ZZAddressBookDataProvider.h"
#import "ZZFriendDomainModel.h"

@implementation ZZMenuInteractor

- (void)loadData
{
    //TODO:
    [[ZZAddressBookDataProvider loadContacts] subscribeNext:^(id x) {
        
        [self.output addressBookDataLoaded:x];
    }];
    
    //TODO: network request to server
    

    
}

@end
