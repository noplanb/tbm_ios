//
// Created by Maksim Bazarov on 22.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMStateScreenViewController.h"
#import "TBMSecretScreenPresenter.h"
#import "TBMStateScreenView.h"

@interface TBMStateScreenViewController ()
@property(nonatomic) TBMSecretScreenPresenter *presenter;
@end

@implementation TBMStateScreenViewController {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        CGRect frame = self.view.frame;
        self.view = [[TBMStateScreenView alloc] initWithFrame:frame];
        [self setupNavigationBar];
    }
    return self;
}

- (void)setupNavigationBar {
    self.title = @"State screen";
}

- (instancetype)initWithPresenter:(TBMSecretScreenPresenter *)presenter {
    self = [self init];
    if (self) {
        self.presenter = presenter;
    }
    return self;
}
@end