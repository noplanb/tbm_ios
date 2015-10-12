//
//  ZZAddressBookDataProvider.m
//  Zazo
//
//  Created by ANODA on 6/20/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZAddressBookDataProvider.h"
#import "APAddressBook.h"
#import "APContact.h"
#import "NSObject+ANRACAdditions.h"
#import "APPhoneWithLabel.h"
#import "NSString+ANAdditions.h"
#import "ZZFriendDomainModel.h"
#import "ZZContactDomainModel.h"
#import "ZZUserPresentationHelper.h"

static APAddressBook* addressBook = nil;

@implementation ZZAddressBookDataProvider

+ (RACSignal*)loadContactsWithContactsRequest:(BOOL)shouldRequest
{
    if (shouldRequest)
    {
        return [[self _requestAccess] flattenMap:^RACStream *(id value) {
            
            if ([value boolValue])
            {
                return [self _loadData];
            }
            else
            {
                return [RACSignal error:nil];
            }
        }];
    }
    else
    {
        RACSignal* loadSignal = [RACSignal empty];
        switch([APAddressBook access])
        {
            case APAddressBookAccessGranted:
            {
                loadSignal = [self _loadData];
            }
                break;
            default: break;
        }
        return loadSignal;
    }
}

+ (RACSignal*)_requestAccess
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [APAddressBook requestAccess:^(BOOL granted, NSError *error) {
            [NSObject an_handleSubcriber:subscriber withObject:@(granted) error:error];
        }];
        
        return [RACDisposable disposableWithBlock:^{}];
    }];
}


#pragma mark - Private

+ (RACSignal*)_loadData
{
    if (!addressBook)
    {
        addressBook = [[APAddressBook alloc] init];
    }
    addressBook.fieldsMask = APContactFieldFirstName | APContactFieldLastName  | APContactFieldPhonesWithLabels | APContactFieldEmails;
    
    addressBook.filterBlock = ^BOOL(APContact *contact) {
        return (contact.firstName.length);
    };
    
    [addressBook startObserveChangesWithCallback:^{
        addressBook = [[APAddressBook alloc] init];
    }];
    
    addressBook.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES],
                                    [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES]];
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        
        [addressBook loadContactsOnQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) completion:^(NSArray *contacts, NSError *error) {
            
            ANDispatchBlockToBackgroundQueue(^{
            
                NSMutableDictionary* result = [NSMutableDictionary new];
                [contacts enumerateObjectsUsingBlock:^(APContact*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                   
                    ZZContactDomainModel* item = [ZZContactDomainModel modelWithFirstName:obj.firstName lastName:obj.lastName];
                    ZZContactDomainModel* existingItem = result[[item.fullName lowercaseString]];
                    if (existingItem)
                    {
                        item = existingItem;
                    }
                    
                    item = [self _fillUserModel:item fromContact:obj];
                    result[[item.fullName lowercaseString]] = item;
                }];
                
                [NSObject an_handleSubcriber:subscriber withObject:result error:error];
            });
        }];
        return [RACDisposable disposableWithBlock:^{}];
        
    }] map:^id(NSDictionary* result) {
        
        NSArray* value = [result allValues];
        
        return [value sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES]]];
    }];
}

+ (ZZContactDomainModel*)_fillUserModel:(ZZContactDomainModel*)model fromContact:(APContact*)contact
{
    if (!ANIsEmpty(contact.firstName))
    {
        if (!model)
        {
            model = [ZZContactDomainModel modelWithFirstName:contact.firstName lastName:contact.lastName];
        }
        
        NSArray* phones = [[contact.phonesWithLabels.rac_sequence map:^id(APPhoneWithLabel* value) {
            ZZCommunicationDomainModel* communication = [ZZCommunicationDomainModel new];
            communication.contact = [value.phone an_stripAllNonNumericCharacters];
            communication.label = value.localizedLabel;
            return communication;
        }] array];
        
        NSSet* modelPhones = model.phones ? [NSSet setWithArray:model.phones] : [NSSet set];
        NSSet* allPhones = [modelPhones setByAddingObjectsFromArray:phones ? : @[]];
        model.phones = [allPhones allObjects];
        
        model.emails = [contact.emails copy];
    }
    return model;
}

@end
