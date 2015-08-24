//
//  ZZAddressBookDataProvider.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 6/20/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ZZAddressBookDataProvider : NSObject

+ (RACSignal*)loadContacts;

@end
