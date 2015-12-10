//
//  ZZUserDataUpdater.h
//  Zazo
//
//  Created by Vitaly Cherevaty on 12/9/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZZUserDomainModel;

@interface ZZUserDataUpdater : NSObject

+ (ZZUserDomainModel*)upsertUserWithModel:(ZZUserDomainModel*)model;

@end
