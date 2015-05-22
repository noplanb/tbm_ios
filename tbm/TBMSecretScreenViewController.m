//
// Created by Maksim Bazarov on 21.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMSecretScreenViewController.h"
#import "TBMSecretScreenView.h"
#import "TBMSecretScreenPresenter.h"

@interface TBMSecretScreenViewController ()
@property(nonatomic, strong) TBMSecretScreenPresenter *presenter;
@end

@implementation TBMSecretScreenViewController {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        CGRect frame = self.view.frame;
        self.view = [[TBMSecretScreenView alloc] initWithFrame:frame ];
        [self setupNavigationBar];
    }
    return self;
}

- (void)setupNavigationBar {
    self.title = @"Secret screen";

    //Done button - returns to the Registration screen or the HomeView screen as appropriate.
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = doneButton;

    // Dispatch - Button - on tap: dispatches log to rollbar in the same way that calling OB_ERROR would.
    UIBarButtonItem *dispatchButton = [[UIBarButtonItem alloc] initWithTitle:@"Dispatch" style:UIBarButtonItemStylePlain target:self action:@selector(dispatchButtonAction:)];
    self.navigationItem.rightBarButtonItem = dispatchButton;
}

- (instancetype)initWithPresenter:(TBMSecretScreenPresenter *)presenter {
    self = [self init];
    if (self) {
        self.presenter = presenter;
        TBMSecretScreenView *view = (TBMSecretScreenView*)self.view;
        view.eventHandler = presenter;
    }
    return self;
}

- (void)backButtonAction:(id)sender {
    [self.presenter backButtonDidPress];
}

- (void)dispatchButtonAction:(id)sender {
    [self.presenter dispatchButtonDidPress];
}

@end