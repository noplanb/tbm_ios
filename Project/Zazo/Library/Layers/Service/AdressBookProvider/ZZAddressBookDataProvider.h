//
//  ZZAddressBookDataProvider.h
//  Zazo
//
//  Created by ANODA on 6/20/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ZZAddressBookDataProvider : NSObject

+ (RACSignal*)loadContactsWithContactsRequest:(BOOL)shouldRequest;
+ (void)resetAddressBook;

+ (BOOL)isAccessGranted;

@end
