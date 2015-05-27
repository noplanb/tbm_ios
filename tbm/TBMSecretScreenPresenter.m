//
// Created by Maksim Bazarov on 22.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <OBLogger/OBLogViewController.h>
#import "TBMSecretScreenPresenter.h"
#import "TBMSecretScreenViewController.h"
#import "TBMStateScreenViewController.h"
#import "TBMConfig.h"

@interface TBMSecretScreenPresenter ()

@property(nonatomic, weak) UIViewController *presentedController;
@property(nonatomic, strong) UINavigationController *navigationController;
@property(nonatomic, strong) OBLogViewController *logScreen;
@property(nonatomic, strong) TBMSecretScreenViewController *secretScreen;
@property(nonatomic, strong) TBMStateScreenViewController *stateScreen;

@end

@implementation TBMSecretScreenPresenter

#pragma mark - Interface

-(void)presentSecretScreenFromController:(UIViewController *)presentedController {
    OB_INFO(@"TBMSecretScreenPresenter: presentSecretScreenFromController");
    self.presentedController = presentedController;
    [presentedController  presentViewController:self.navigationController animated:YES completion:nil];
}


#pragma mark - Initialization

- (UINavigationController *)navigationController {
    if (!_navigationController) {
        _navigationController = [[UINavigationController alloc] initWithRootViewController:self.secretScreen];
    }
    return _navigationController;
}

- (OBLogViewController *)logScreen {
    if (!_logScreen) {
        _logScreen = [OBLogViewController instance];
    }
    return _logScreen;
}

- (TBMSecretScreenViewController *)secretScreen {
    if (!_secretScreen) {
        _secretScreen = [[TBMSecretScreenViewController alloc] initWithPresenter:self];
    }
    return _secretScreen;
}

- (TBMStateScreenViewController *)stateScreen {
    if (!_stateScreen) {
        _stateScreen = [[TBMStateScreenViewController alloc] init];
    }
    return _stateScreen;
}

#pragma mark - Present child screens

- (void)presentLogScreen {
    [self.navigationController pushViewController:self.logScreen animated:YES];
}

- (void)presentStateScreen {
    [self.navigationController pushViewController:self.stateScreen animated:YES];
}

#pragma mark - Dismiss

- (void)dismiss {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - Event handling

- (void)backButtonDidPress {
    [self dismiss];
}


- (void)dispatchButtonDidPress {

}

- (void)debugSwitchDidChangeTo:(BOOL)on {
    if (on) {
        [TBMConfig changeDeviceDebugModeTo:TBMConfigDeviceDebugModeDev];
    } else {
        [TBMConfig changeDeviceDebugModeTo:TBMConfigDeviceDebugModeProd];
    }
    [self reload];
}

- (void)reload {
    [self.secretScreen reloadData];

}

- (void)crashButtonDidPress {

}

- (void)logButtonDidPress {
    [self presentLogScreen];
}

- (void)stateButtonDidPress {
    [self presentStateScreen];
}

- (void)serverSegmentedControlDidChangeTo:(NSInteger)index {
    [TBMConfig changeServerTo:index];
    [self reload];
}
@end