//
//  TBMContactsManager.m
//  tbm
//
//  Created by Sani Elfishawy on 11/12/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMContactsManager.h"
#import <AddressBook/AddressBook.h>

@interface TBMContactsManager()
@property (nonatomic) CFArrayRef allPeople;
@property (nonatomic) CFMutableArrayRef sortedPeople;
@property (nonatomic) NSMutableDictionary *contactsDirectory;
@end


@implementation TBMContactsManager

+ (instancetype)sharedInstance{
    static dispatch_once_t once;
    static TBMContactsManager *sharedContactsManager;
    dispatch_once(&once, ^ { sharedContactsManager = [[self alloc] init]; });
    return sharedContactsManager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setPeople];
        [self sortPeople];
        
        [self loadContactsDirectory];
        [self setFullnamesHavingPhone];
        NSLog(@"%@", _fullnamesHavingPhone);
        
        //[self printPhones];
    }
    return self;
}

- (void)setFullnamesHavingPhone{
    NSLog(@"#################  setFullnamesHavingMobile:    %@", kABPersonPhoneMobileLabel);
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
        NSLog(@"Checking %@", [pn objectForKey:kContactsManagerPhoneTypeKey]);
        if ([[pn objectForKey:kContactsManagerPhoneTypeKey] isEqual:(__bridge id)ABAddressBookCopyLocalizedLabel(kABPersonPhoneMobileLabel)])
            return YES;
    }
    return NO;
}

- (BOOL)directoryEntryHasPhone:(NSString *)fullname{
    NSArray *pns = [[self.contactsDirectory objectForKey:fullname] objectForKey:kContactsManagerPhonesKey];
    return [pns count] > 0;
}

- (NSDictionary *)directoryEntryWithFullname:(NSString *)fullname{
    return [self.contactsDirectory objectForKey:fullname];
}

- (void)setPeople{
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions (NULL, &error);
    if (error != nil)
        NSLog(@"%s ***** ERROR: %@", __PRETTY_FUNCTION__, error);
    
    BOOL accessGranted = [self addressBookAccessStatus: addressBook];
    if (accessGranted){
        _allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSLog(@"%ld", CFArrayGetCount(_allPeople));
    } else {
        NSLog(@"ERROR: no access granted");
    }
}

- (void)loadContactsDirectory{
    if (self.contactsDirectory == nil)
        self.contactsDirectory = [[NSMutableDictionary alloc] init];
    
    for (CFIndex i=0; i<CFArrayGetCount(self.sortedPeople); i++) {
        ABRecordRef p = CFArrayGetValueAtIndex(self.sortedPeople, i);
        CFStringRef firstName = ABRecordCopyValue(p, kABPersonFirstNameProperty);
        
        if (firstName == NULL){
            NSLog(@"Skipping NULL first name");
            continue;
        }
        
        CFStringRef lastName = ABRecordCopyValue(p, kABPersonLastNameProperty);
        if (lastName == NULL){
            NSLog(@"Normalizing null last name");
            lastName = CFSTR("");
        }
        
        NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        NSMutableDictionary *entry = [self.contactsDirectory objectForKey:fullName];
        
        if (entry == nil){
            NSLog(@"");
            NSLog(@"================");
            NSLog(@"Creating entry for %@", fullName);
            entry = [[NSMutableDictionary alloc] init];
            [entry setObject:(__bridge id)(firstName) forKey:kContactsManagerFirstNameKey];
            [entry setObject:(__bridge id)(lastName) forKey:kContactsManagerLastNameKey];
            [entry  setObject:[self phoneNumbersWithRecord:p] forKey:kContactsManagerPhonesKey];
            NSLog(@"Creating phone numbers %@", [self phoneNumbersWithRecord:p]);
            [self.contactsDirectory setObject:entry forKey:fullName];
        } else {
            NSLog(@"Found entry for %@", fullName);
            NSLog(@"Added phone numbers %@", [self phoneNumbersWithRecord:p]);
            [(NSMutableSet *)[entry objectForKey:kContactsManagerPhonesKey] unionSet:[self phoneNumbersWithRecord:p]];
            NSLog(@"Unique numbers: %@", [entry objectForKey:kContactsManagerPhonesKey]);
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
            NSLog(@"%@ %@", phoneNumber, ll);
        }
    }
}

- (void)printNames{
    for (CFIndex i=0; i<CFArrayGetCount(_sortedPeople); i++){
        ABRecordRef p = CFArrayGetValueAtIndex(_sortedPeople, i);
        CFStringRef fn = ABRecordCopyValue(p, kABPersonFirstNameProperty);
        CFStringRef ln = ABRecordCopyValue(p, kABPersonLastNameProperty);
        NSLog(@"%@ %@", fn, ln);
    }
}


//-----------------------
// Request and get access
//-----------------------
-(BOOL) addressBookAccessStatus: (ABAddressBookRef) addressBook{
    __block BOOL accessGranted = NO;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        accessGranted = granted;
        dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    return accessGranted;
}

@end
