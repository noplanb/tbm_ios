//
//  ZZAddressBookDataProvider.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 6/20/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZAddressBookDataProvider.h"
#import "APAddressBook.h"
#import "APContact.h"
#import "NSObject+ANRACAdditions.h"
#import "APPhoneWithLabel.h"
#import "NSString+ANAdditions.h"
#import "ZZContactDomainModel.h"

static APAddressBook* addressBook = nil;

@implementation ZZAddressBookDataProvider

+ (RACSignal*)loadContacts
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


#pragma mark - Private

+ (RACSignal*)_loadData
{
    if (!addressBook)
    {
        addressBook = [[APAddressBook alloc] init];
    }
    addressBook.fieldsMask = APContactFieldFirstName | APContactFieldLastName  | APContactFieldPhones;
    
    addressBook.filterBlock = ^BOOL(APContact *contact) {
        return ((contact.phones.count > 0) | (contact.firstName.length));
    };
    
    addressBook.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES],
                                    [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES]];

    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [addressBook loadContacts:^(NSArray *contacts, NSError *error) {
            
            ANDispatchBlockToBackgroundQueue(^{
                NSArray* contactData = [[contacts.rac_sequence map:^id(id value) {
                    return [self _userModelFromContact:value];
                }] array];
                
                [NSObject an_handleSubcriber:subscriber withObject:contactData error:error];
            });
        }];
        return [RACDisposable disposableWithBlock:^{}];
    }];
}

+ (ZZContactDomainModel*)_userModelFromContact:(APContact*)contact
{
    ZZContactDomainModel* model;
    
    if (!ANIsEmpty(contact.firstName) && !ANIsEmpty(contact.phones))
    {
        model = [ZZContactDomainModel new];
        
        model.firstName = contact.firstName;
        model.lastName = contact.lastName;
        
        NSArray* phones = [[contact.phones.rac_sequence map:^id(NSString* value) {
            return [value an_stripAllNonNumericCharacters];
        }] array];
        
        model.phones = [NSSet setWithArray:phones ? : @[]];
    }
    
    return model;
}

@end
