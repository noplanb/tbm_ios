//
// Created by Maksim Bazarov on 21.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <AFNetworking/AFURLResponseSerialization.h>
#import "TBMSecretScreenViewController.h"
#import "TBMSecretScreenView.h"
#import "TBMSecretScreenPresenter.h"
#import "TBMDebugData.h"
#import "TBMDebugData.h"

@interface TBMSecretScreenViewController ()
@property(nonatomic, strong) TBMSecretScreenPresenter *presenter;
@end

@implementation TBMSecretScreenViewController

//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        CGRect frame = self.view.frame;
//
//        TBMSecretScreenView *view = [[TBMSecretScreenView alloc] initWithFrame:frame];
//        [view updateUserInterfaceWithData:[[TBMDebugData alloc] init]];
//        self.view = view;
//        [self setupNavigationBar];
//    }
//    return self;
//}

//- (void)setupNavigationBar {
//    self.title = @"Secret screen";
//
//    //Done button - returns to the Registration screen or the HomeView screen as appropriate.
//    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonAction:)];
//    self.navigationItem.leftBarButtonItem = doneButton;
//}

//- (instancetype)initWithPresenter:(TBMSecretScreenPresenter *)presenter {
//    self = [self init];
//    if (self) {
//        self.presenter = presenter;
//        TBMSecretScreenView *view = (TBMSecretScreenView *) self.view;
//        view.eventHandler = presenter;
//    }
//    return self;
//}

//- (void)backButtonAction:(id)sender {
//    [self.presenter backButtonDidPress];
//}
//
//- (void)dispatchButtonAction:(id)sender {
//    [self.presenter dispatchButtonDidPress];
//}
//
//
//- (void)reloadData {
//    [(TBMSecretScreenView *) self.view updateUserInterfaceWithData:[[TBMDebugData alloc] init]];
//}
@end