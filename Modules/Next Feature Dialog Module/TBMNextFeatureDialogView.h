//
// Created by Maksim Bazarov on 20/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBMDialogViewInterface.h"

@class TBMNextFeatureDialogPresenter;
@protocol TBMGridModuleInterface;


@interface TBMNextFeatureDialogView : UIView <TBMDialogViewInterface>

@property(nonatomic, weak) TBMNextFeatureDialogPresenter *presenter;

@end