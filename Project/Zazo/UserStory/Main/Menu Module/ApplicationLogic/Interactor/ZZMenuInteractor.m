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
    
    NSMutableArray* dataArray = [NSMutableArray array];
    
    [[ZZAddressBookDataProvider loadContacts] subscribeNext:^(id x) {
       
//        [self.output addressBookDataLoaded:x];
      
        
        //TODO: add here data from server only for test!!!
        [dataArray addObjectsFromArray:x];
        for (int i = 0;i<3;i++)
        {
            ZZFriendDomainModel* model = [ZZFriendDomainModel new];
            model.firstName = [NSString stringWithFormat:@"name %i",i];
            model.lastName = [NSString stringWithFormat:@"lastname %i",i];
            model.idTbm = [NSString stringWithFormat:@"id%i",i];
            model.hasApp = YES;
            
            [dataArray addObject:model];
        }
        
        [self.output addressBookDataLoaded:dataArray];
        
    }];
    
    //TODO: network request to server
    

    
}

@end
