//
//  ZZGridCollectionController.h
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ANCollectionController.h"

@class ZZGridDomainModel;

@protocol ZZGridCollectionControllerDelegate <NSObject>

- (void)selectedViewWithModel:(ZZGridDomainModel*)model;

@end

@interface ZZGridCollectionController : ANCollectionController

@property (nonatomic, weak) id <ZZGridCollectionControllerDelegate> delegate;

@end
