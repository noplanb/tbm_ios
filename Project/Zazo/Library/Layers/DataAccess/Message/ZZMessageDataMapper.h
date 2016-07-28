//
//  ZZMessageDataMapper.h
//  Zazo
//
//  Created by Server on 28/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBMMessage.h"
#import "ZZMessageDomainModel.h"

@interface ZZMessageDataMapper : NSObject

+ (void)fillModel:(ZZMessageDomainModel *)model fromEntity:(TBMMessage *)entity;
+ (void)fillEntity:(TBMMessage *)entity fromModel:(ZZMessageDomainModel *)model;

@end
