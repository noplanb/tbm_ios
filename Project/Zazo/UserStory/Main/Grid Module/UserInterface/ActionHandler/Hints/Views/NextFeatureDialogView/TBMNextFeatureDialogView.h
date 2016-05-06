//
// Created by Maksim Bazarov on 20/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridModuleInterface.h"

@class TBMNextFeatureDialogPresenter;

@interface TBMNextFeatureDialogView : UIView

+ (void)showNextFeatureDialogWithPresentedView:(UIView *)presentedView completionBlock:(void (^)())completionBlock;

@end