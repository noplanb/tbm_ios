//
//  ZZGridCollectionCellStateViewFactory.h
//  Zazo
//
//  Created by ANODA on 03/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZGridCollectionCellBaseStateView.h"

@interface ZZGridCollectionCellStateViewFactory : NSObject

- (ZZGridCollectionCellBaseStateView *)stateViewWithPresentedView:(UIView <ZZGridCollectionCellBaseStateViewDelegate> *)presentedView
                                                withCellViewModel:(ZZGridCellViewModel *)cellViewModel;

@end
