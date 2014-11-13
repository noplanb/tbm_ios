//
//  TBMContactsManager.h
//  tbm
//
//  Created by Sani Elfishawy on 11/12/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSString * kContactsManagerFirstNameKey = @"firstName";
static const NSString * kContactsManagerLastNameKey = @"lastName";
static const NSString * kContactsManagerPhoneTypeKey = @"phoneType";
static const NSString * kContactsManagerPhoneNumberKey = @"phoneNumber";
static const NSString * kContactsManagerPhonesKey = @"phones";

@interface TBMContactsManager : NSObject
// Instantiation (singleton)
+ (instancetype)sharedInstance;

// Public properties
- (void)prefetchOnlyIfHasAccess;
- (NSArray *) getFullNamesHavingAnyPhone;
- directoryEntryWithFullname:(NSString *)fullname;
@end
