//
//  ZZCredentialsKeyData.h
//  Zazo
//
//  Created by Rinat on 22/09/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZCredentialsKeyData : NSObject

@property (nonatomic, copy) NSString *regionKey;
@property (nonatomic, copy) NSString *bucketKey;
@property (nonatomic, copy) NSString *accessKey;
@property (nonatomic, copy) NSString *secretKey;

+ (instancetype)keyDataForType:(NSString *)type;

@end
