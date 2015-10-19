/**
 *
 * Feature unlock dialog base class
 *
 * Created by Maksim Bazarov on 10/06/15.
 * Copyright (c) 2015 No Plan B. All rights reserved.
 */
#import "ZZGridModuleInterface.h"


@class TBMFeatureUnlockModulePresenter;
@class ZZSoundEffectPlayer;

@interface TBMFeatureUnlockDialogView : UIView

+ (void)showFeatureDialog:(NSString*)dialog withPresentedView:(UIView*)presentedView completionBlock:(void(^)())completionBlock;

@end