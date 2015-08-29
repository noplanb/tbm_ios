//
//  TBMKeyChainWrapper.m
//  tbm
//
//  Created by Sani Elfishawy on 1/3/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//
#import <Security/Security.h>
#import "TBMKeyChainWrapper.h"
#import "OBLogger.h"

@implementation TBMKeyChainWrapper

//
// get
//
+ (NSString *)getItem:(NSString *)key{
    // OB_INFO(@"KeyChainWrapper: get key=%@", key);
    CFDataRef result = nil;
    NSMutableDictionary *item = [self keyChainItem:key];
    item[(__bridge id) kSecReturnData] = (__bridge id)kCFBooleanTrue;
    OSStatus sts = SecItemCopyMatching((__bridge CFDictionaryRef)item, (CFTypeRef *)&result);
    
    if (sts == errSecItemNotFound)
        return nil;
    
    if (sts != errSecSuccess){
        OB_ERROR(@"KeyChainWrapper: get: Error adding getting item: %d This should never happen.", (int)sts);
        return nil;
    }
    
    NSData * d = (__bridge_transfer NSData *)result;
    return [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
}

//
// put
//
+ (void)putItem:(NSString *)key value:(NSString *)value{
    // OB_INFO(@"KeyChainWrapper: put key=%@, value=%@", key, value);
    NSString *got = [self getItem:key];
    if (got != nil){
        [self update:key value:value];
        return;
    }
    NSMutableDictionary *item = [self keyChainItem:key];
    item[(__bridge id) kSecValueData] = [value dataUsingEncoding:NSUTF8StringEncoding];
    OSStatus sts = SecItemAdd((__bridge CFDictionaryRef)item, NULL);
    if (sts != errSecSuccess)
        OB_ERROR(@"KeyChainWrapper: put: Error adding item: %d This should never happen.", (int)sts);
}

//
// update
//
+ (void)update:(NSString *)key value:(NSString *)value{
    // OB_INFO(@"KeyChainWrapper: update key=%@, value=%@", key, value);
    if ([self getItem:key] == nil) {
        OB_ERROR(@"KeyChainWrapper: update: item not found. This should never happen.");
        return;
    }
    
    NSDictionary *attrToUpdate = @{(__bridge id)kSecValueData: [value dataUsingEncoding:NSUTF8StringEncoding]};
    OSStatus sts =  SecItemUpdate((__bridge CFDictionaryRef)[self keyChainItem:key], (__bridge CFDictionaryRef) attrToUpdate);
    
    if (sts != errSecSuccess)
        OB_ERROR(@"KeyChainWrapper: update: Error updating item: %d This should never happen.", (int)sts);
}

//
// delete
//
+ (void)deleteItem:(NSString *)key{
    OSStatus sts = SecItemDelete((__bridge CFDictionaryRef)[self keyChainItem:key]);
    
    if (sts != errSecSuccess && sts != errSecItemNotFound)
        OB_ERROR(@"KeyChainWrapper: delete: Error deleting item: %d This should never happen.", (int)sts);
}

+ (NSMutableDictionary *)keyChainItem:(NSString *)key{
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    item[(__bridge id)kSecClass] = (__bridge id)kSecClassInternetPassword;
    item[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAlways;
    item[(__bridge id)kSecAttrAccount] = key;
    return item;
}


@end
