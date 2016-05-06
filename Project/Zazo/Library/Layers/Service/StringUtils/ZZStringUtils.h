//
//  ZZStringUtils.h
//  Zazo
//
//  Created by ANODA on 17/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ZZStringUtils : NSObject

+ (NSString *)jsonWithDictionary:(NSDictionary *)dict;

+ (NSDictionary *)dictionaryWithJson:(NSString *)jsonString;

@end
