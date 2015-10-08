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
    addressBook.fieldsMask = APContactFieldFirstName | APContactFieldLastName  | APContactFieldPhonesWithLabels;
    
    addressBook.filterBlock = ^BOOL(APContact *contact) {
        return ((contact.phones.count > 0) | (contact.firstName.length));
    };
    
    [addressBook startObserveChangesWithCallback:^{
        addressBook = [[APAddressBook alloc] init];
    }];
    
    addressBook.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES],
                                    [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES]];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [addressBook loadContacts:^(NSArray *contacts, NSError *error) {
            
            ANDispatchBlockToBackgroundQueue(^{
                
                __block NSMutableArray* result = [NSMutableArray new];
                [contacts enumerateObjectsUsingBlock:^(APContact*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                   
                    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"fullName =[c] %@", [ZZUserPresentationHelper fullNameWithFirstName:obj.firstName lastName:obj.lastName]];
              
                    NSArray* items = [result filteredArrayUsingPredicate:predicate];
                    id item = [self _userModelFromContact:obj container:[items firstObject]];
                    if (item)
                    {
                        [result removeObject:item];
                        [result addObject:item];
                    }
                }];
                
                [NSObject an_handleSubcriber:subscriber withObject:result error:error];
            });
        }];
        return [RACDisposable disposableWithBlock:^{}];
    }];
}

+ (ZZContactDomainModel*)_userModelFromContact:(APContact*)contact container:(ZZContactDomainModel*)container
{
    ZZContactDomainModel* model = container;
    
    if (!ANIsEmpty(contact.firstName))
    {
        if (!model)
        {
            model = [ZZContactDomainModel new];
            model.firstName = contact.firstName;
            model.lastName = contact.lastName;
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
    }
    return model;
}

@end
