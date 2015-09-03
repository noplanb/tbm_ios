//
//  ZZGridCollectionCellStateViewFactory.m
//  Zazo
//
//  Created by Dmitriy Frolow on 03/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridCollectionCellStateViewFactory.h"
#import "ZZGridCollectionNudgeStateView.h"
#import "ZZGridCollectionCellRecordStateView.h"
#import "ZZGridCollectionCellPreviewStateView.h"

@implementation ZZGridCollectionCellStateViewFactory

- (ZZGridCollectionCellBaseStateView *)stateViewWithPresentedView:(UIView <ZZGridCollectionCellBaseStateViewDelegate> *)presentedView
                                                withCellViewModel:(ZZGridCollectionCellViewModel *)cellViewModel
{
    ZZGridCollectionCellBaseStateView* stateView;
    
    if (cellViewModel.domainModel.relatedUser.videos.count > 0) // TODO: this condition only for test!, change it later
    {
        stateView = [[ZZGridCollectionCellPreviewStateView alloc] initWithPresentedView:presentedView withModel:cellViewModel];
    }
    else if (cellViewModel.domainModel.relatedUser.hasApp)
    {
        stateView = [[ZZGridCollectionCellRecordStateView alloc] initWithPresentedView:presentedView withModel:cellViewModel];
    }
    else if (!cellViewModel.domainModel.relatedUser.hasApp)
    {
        stateView = [[ZZGridCollectionNudgeStateView alloc] initWithPresentedView:presentedView withModel:cellViewModel];
    }
    
    return stateView;
}

@end
