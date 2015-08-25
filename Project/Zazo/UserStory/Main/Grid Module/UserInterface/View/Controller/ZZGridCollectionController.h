//
//  ZZGridCollectionController.h
//  Zazo
//
//  Created by ANODA.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ANCollectionController.h"

@protocol ZZGridCollectionControllerDelegate <NSObject>

- (void)selectedViewWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface ZZGridCollectionController : ANCollectionController

@property (nonatomic, weak) id <ZZGridCollectionControllerDelegate> delegate;

@end
