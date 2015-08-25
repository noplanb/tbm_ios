//
//  ZZGridModuleInterface.h
//  Zazo
//
//  Created by ANODA on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@protocol ZZGridModuleInterface <NSObject>

- (void)presentMenu;
- (void)selectedCollectionViewWithIndexPath:(NSIndexPath *)indexPath;

@end
