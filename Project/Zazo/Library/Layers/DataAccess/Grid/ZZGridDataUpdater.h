//
//  ZZGridDataUpdater.h
//  Zazo
//
//  Created by ANODA on 9/30/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class ZZGridDomainModel;

@interface ZZGridDataUpdater : NSObject

+ (ZZGridDomainModel*)upsertGridModelWithModel:(ZZGridDomainModel*)model;

@end
