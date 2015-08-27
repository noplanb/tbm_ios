//
// Created by Maksim Bazarov on 21.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBMSecretScreenPresenter;
@class TBMDebugData;

@interface TBMSecretScreenViewController : UIViewController

- (id)initWithPresenter:(TBMSecretScreenPresenter *)presenter;

- (void)reloadData;
@end