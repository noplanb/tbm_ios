//
//  ZZGridCollectionCellStateViewFactory.h
//  Zazo
//
//  Created by ANODA on 03/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridStateView.h"

@interface ZZGridCollectionCellStateViewFactory : NSObject

+ (ZZGridStateView *)stateViewWithPresentedView:(UIView <ZZGridCollectionCellBaseStateViewDelegate> *)presentedView
                                                withCellViewModel:(ZZGridCellViewModel *)cellViewModel;

@end
