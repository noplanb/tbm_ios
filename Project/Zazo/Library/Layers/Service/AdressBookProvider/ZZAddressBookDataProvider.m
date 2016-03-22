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
#import "NSString+ANAdditions.h"
#import "ZZFriendDomainModel.h"
#import "ZZContactDomainModel.h"
#import "ZZUserPresentationHelper.h"

static APAddressBook* _addressBook = nil;

@implementation ZZAddressBookDataProvider

+ (void)resetAddressBook
{
    _addressBook = nil;
}

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
        if ([self isAccessGranted])
        {
            loadSignal = [self _loadData];
        }
        return loadSignal;
    }
}

+ (BOOL)isAccessGranted
{
    return ([APAddressBook access] == APAddressBookAccessGranted);
}

+ (RACSignal*)_requestAccess
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        APAddressBook* aBook = [self _addressbook];
        
        [aBook requestAccess:^(BOOL granted, NSError *error) {
            [NSObject an_handleSubcriber:subscriber withObject:@(granted) error:error];
        }];
        
        return [RACDisposable disposableWithBlock:^{}];
    }];
}


#pragma mark - Private

+ (APAddressBook*)_addressbook
{
    if (!_addressBook)
    {
        _addressBook = [[APAddressBook alloc] init];
        [_addressBook startObserveChangesWithCallback:^{
            _addressBook = nil;
        }];
    }
    return _addressBook;
}

+ (RACSignal*)_loadData
{
    APAddressBook* addressBook = [self _addressbook];
    addressBook.fieldsMask = APContactFieldAll;

    addressBook.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name.firstName" ascending:YES],
                                    [NSSortDescriptor sortDescriptorWithKey:@"name.lastName" ascending:YES]];
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        
        [addressBook loadContactsOnQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) completion:^(NSArray *contacts, NSError *error) {
            
            ANDispatchBlockToBackgroundQueue(^{
            
                NSMutableDictionary* result = [NSMutableDictionary new];
                [contacts enumerateObjectsUsingBlock:^(APContact*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                   
                    NSString *firstName = obj.name.firstName;
                    
                    if (ANIsEmpty(firstName) && ANIsEmpty(obj.name.lastName) && !ANIsEmpty(obj.name.compositeName))
                    {
                        firstName = obj.name.compositeName; // Use company name if nothing else
                    }
                    
                    ZZContactDomainModel* item = [ZZContactDomainModel modelWithFirstName:firstName lastName:obj.name.lastName];
                    ZZContactDomainModel* existingItem = result[[item.fullName lowercaseString]];
                    if (existingItem)
                    {
                        item = existingItem;
                    }
                    item = [self _fillUserModel:item fromContact:obj];
                    result[[item.fullName lowercaseString]] = item;
                }];
                
                [result removeObjectForKey:@""];
                
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
    if (!ANIsEmpty(contact.name.firstName))
    {
        if (!model)
        {
            model = [ZZContactDomainModel modelWithFirstName:contact.name.firstName lastName:contact.name.lastName];
        }
        
        model.thumbnail = contact.thumbnail;
        
        NSArray* phones = [[contact.phones.rac_sequence map:^id(APPhone* value) {
            ZZCommunicationDomainModel* communication = [ZZCommunicationDomainModel new];
            communication.contact = value.number;
            communication.label = value.localizedLabel;
            return communication;
        }] array];
        
        NSSet* modelPhones = model.phones ? [NSSet setWithArray:model.phones] : [NSSet set];
        NSSet* allPhones = [modelPhones setByAddingObjectsFromArray:phones ? : @[]];
        model.phones = [allPhones allObjects];
        
        model.emails = [[contact.emails.rac_sequence map:^id(APEmail* value) {
            return value.address;
        }] array];
    }
    return model;
}

@end
