//
//  ZZGridCollectionCellStateViewFactory.h
//  Zazo
//
//  Created by Dmitriy Frolow on 03/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZGridCollectionCellBaseStateView.h"

@interface ZZGridCollectionCellStateViewFactory : NSObject

- (ZZGridCollectionCellBaseStateView *)stateViewWithPresentedView:(UIView <ZZGridCollectionCellBaseStateViewDelegate> *)presentedView
                                                withCellViewModel:(ZZGridCollectionCellViewModel *)cellViewModel;

@end
