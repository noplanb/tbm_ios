//
// Created by Maksim Bazarov on 22.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBMSecretScreenPresenter;
@class TBMDebugData;

@interface TBMSecretScreenView : UIView <UITextFieldDelegate>

/**
* Event handler
*/
@property(nonatomic, weak) TBMSecretScreenPresenter *eventHandler;

/**
* Updates data on user interface
*/
- (void)updateUserInterfaceWithData:(TBMDebugData *)data;
@end