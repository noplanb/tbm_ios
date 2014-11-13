//
//  TBMContactsManager.m
//  tbm
//
//  Created by Sani Elfishawy on 11/12/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMContactsManager.h"
#import <AddressBook/AddressBook.h>
#import "OBLogger.h"
#import "TBMConfig.h"

@interface TBMContactsManager()
@property (nonatomic) ABAddressBookRef addressBookRef;
@property (nonatomic) CFArrayRef allPeople;
@property (nonatomic) CFMutableArrayRef sortedPeople;
@property (nonatomic) NSMutableDictionary *contactsDirectory;
@property (nonatomic) NSArray *fullnamesHavingPhone;
@property (nonatomic) BOOL isSetup;
@end


@implementation TBMContactsManager

//--------------------------
// Instantiation (singleton)
//--------------------------
+ (instancetype)sharedInstance{
    static dispatch_once_t once;
    static TBMContactsManager *sharedContactsManager;
    dispatch_once(&once, ^ { sharedContactsManager = [[self alloc] init]; });
    return sharedContactsManager;
}

- (instancetype)init{
    self = [super init];
    if (self != nil)
        _isSetup = NO;
    return self;
}

//------------------------
// Public Instance Methods
//------------------------
- (void)prefetchOnlyIfHasAccess{
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized && !self.isSetup)
        [self setup];
}

- (NSArray *) getFullNamesHavingAnyPhone{
    if ([self setup])
        return self.fullnamesHavingPhone;
    else
        return nil;
}

- (NSDictionary *)directoryEntryWithFullname:(NSString *)fullname{
    if ([self setup])
        return [self.contactsDirectory objectForKey:fullname];
    else
        return nil;
}


//-------------------------------------------------
// Setup contactsDirectory and fullnamesHavingPhone
//-------------------------------------------------
- (BOOL)setup{
    if (self.isSetup)
        return YES;
    
    if (![self requestAndCheckAccess]){
        [self alertNeedPermission];
        return NO;
    }
    
    OB_INFO(@"ContactsManager: setting up");
    [self setPeople];
    //[self sortPeople];
    [self loadContactsDirectory];
    [self setFullnamesHavingPhone];
    self.isSetup = YES;
    OB_INFO(@"ContactsManager: setting up complete");
    return YES;
}

- (void)alertNeedPermission{
    NSString *msg = [NSString stringWithFormat:@"You must grant access to contacts for this. Please go to settings/privacy/contacts and grant access to contacts for %@", CONFIG_APP_NAME];
    [[[UIAlertView alloc]
        initWithTitle:@"Need Permission"
        message:msg
        delegate:self
        cancelButtonTitle:@"OK"
        otherButtonTitles:nil] show];
}

- (void)setFullnamesHavingPhone{
    NSMutableArray *fns = [[NSMutableArray alloc] init];
    for (NSString *fn in [self.contactsDirectory allKeys]){
        if ([self directoryEntryHasPhone:fn])
            [fns addObject:fn];
    }
    self.fullnamesHavingPhone = [fns sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 lowercaseString] compare:[obj2 lowercaseString]];
    }];
}

- (BOOL)directoryEntryHasMobile:(NSString *)fullname{
    NSArray *pns = [[self.contactsDirectory objectForKey:fullname] objectForKey:kContactsManagerPhonesKey];
    for (NSDictionary *pn in pns){
        DebugLog(@"Checking %@", [pn objectForKey:kContactsManagerPhoneTypeKey]);
        if ([[pn objectForKey:kContactsManagerPhoneTypeKey] isEqual:(__bridge id)ABAddressBookCopyLocalizedLabel(kABPersonPhoneMobileLabel)])
            return YES;
    }
    return NO;
}

- (BOOL)directoryEntryHasPhone:(NSString *)fullname{
    NSArray *pns = [[self.contactsDirectory objectForKey:fullname] objectForKey:kContactsManagerPhonesKey];
    return [pns count] > 0;
}


- (void)setPeople{
    self.allPeople = ABAddressBookCopyArrayOfAllPeople(self.addressBookRef);
    DebugLog(@"%ld", CFArrayGetCount(_allPeople));
}

- (void)loadContactsDirectory{
    if (self.contactsDirectory == nil)
        self.contactsDirectory = [[NSMutableDictionary alloc] init];
    
    for (CFIndex i=0; i<CFArrayGetCount(self.allPeople); i++) {
        ABRecordRef p = CFArrayGetValueAtIndex(self.allPeople, i);
        CFStringRef firstName = ABRecordCopyValue(p, kABPersonFirstNameProperty);
        
        if (firstName == NULL){
            // DebugLog(@"Skipping NULL first name");
            continue;
        }
        
        CFStringRef lastName = ABRecordCopyValue(p, kABPersonLastNameProperty);
        if (lastName == NULL){
            // DebugLog(@"Normalizing null last name");
            lastName = CFSTR("");
        }
        
        NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        NSMutableDictionary *entry = [self.contactsDirectory objectForKey:fullName];
        
        if (entry == nil){
            // DebugLog(@"");
            // DebugLog(@"================");
            // DebugLog(@"Creating entry for %@", fullName);
            entry = [[NSMutableDictionary alloc] init];
            [entry setObject:(__bridge id)(firstName) forKey:kContactsManagerFirstNameKey];
            [entry setObject:(__bridge id)(lastName) forKey:kContactsManagerLastNameKey];
            [entry  setObject:[self phoneNumbersWithRecord:p] forKey:kContactsManagerPhonesKey];
            // DebugLog(@"Creating phone numbers %@", [self phoneNumbersWithRecord:p]);
            [self.contactsDirectory setObject:entry forKey:fullName];
        } else {
            // DebugLog(@"Found entry for %@", fullName);
            // DebugLog(@"Added phone numbers %@", [self phoneNumbersWithRecord:p]);
            [(NSMutableSet *)[entry objectForKey:kContactsManagerPhonesKey] unionSet:[self phoneNumbersWithRecord:p]];
            // DebugLog(@"Unique numbers: %@", [entry objectForKey:kContactsManagerPhonesKey]);
        }
    }
}

- (NSMutableSet *)phoneNumbersWithRecord:(ABRecordRef)record{
    NSMutableSet *result = [[NSMutableSet alloc] init];
    
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(record, kABPersonPhoneProperty);
    for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
        NSString* phoneNumber = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
        CFStringRef label = ABMultiValueCopyLabelAtIndex(phoneNumbers, i);
        CFStringRef ll = ABAddressBookCopyLocalizedLabel(label);
        
        NSDictionary *entry = @{kContactsManagerPhoneNumberKey: phoneNumber, kContactsManagerPhoneTypeKey:(__bridge id)(ll)};
        [result addObject:entry];
    }
    return result;
}

- (void)sortPeople{
    _sortedPeople = CFArrayCreateMutableCopy(kCFAllocatorDefault, CFArrayGetCount(_allPeople), _allPeople);
    CFArraySortValues(_sortedPeople, CFRangeMake(0,CFArrayGetCount(_allPeople)), (CFComparatorFunction)ABPersonComparePeopleByName,(void *)ABPersonGetSortOrdering());
}

- (void)printPhones{
    for (CFIndex i=0; i<CFArrayGetCount(_allPeople); i++){
        ABRecordRef p = CFArrayGetValueAtIndex(_allPeople, i);
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(p, kABPersonPhoneProperty);
        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
            NSString* phoneNumber = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            CFStringRef label = ABMultiValueCopyLabelAtIndex(phoneNumbers, i);
            CFStringRef ll = ABAddressBookCopyLocalizedLabel(label);
            DebugLog(@"%@ %@", phoneNumber, ll);
        }
    }
}

- (void)printNames{
    for (CFIndex i=0; i<CFArrayGetCount(_sortedPeople); i++){
        ABRecordRef p = CFArrayGetValueAtIndex(_sortedPeople, i);
        CFStringRef fn = ABRecordCopyValue(p, kABPersonFirstNameProperty);
        CFStringRef ln = ABRecordCopyValue(p, kABPersonLastNameProperty);
        DebugLog(@"%@ %@", fn, ln);
    }
}


//-----------------------
// Request and get access
//-----------------------
-(BOOL) requestAndCheckAccess{
    CFErrorRef error = nil;
    self.addressBookRef = ABAddressBookCreateWithOptions (NULL, &error);
    if (error != nil){
        OB_ERROR(@"ContactsManager: requestAndCheckAccess: %@", error);
        return NO;
    }

    __block BOOL accessGranted = NO;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(self.addressBookRef, ^(bool granted, CFErrorRef error) {
        accessGranted = granted;
        dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    return accessGranted;
}

@end
