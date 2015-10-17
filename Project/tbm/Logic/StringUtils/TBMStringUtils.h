//
//  TBMStringUtils.h
//  tbm
//
//  Created by Sani Elfishawy on 5/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

@interface TBMStringUtils : NSObject

+ (NSString *)randomStringofLength:(int)length;

+ (NSString *)jsonWithDictionary:(NSDictionary *)dict;
+ (NSDictionary *)dictionaryWithJson:(NSString *)jsonString;

@end
