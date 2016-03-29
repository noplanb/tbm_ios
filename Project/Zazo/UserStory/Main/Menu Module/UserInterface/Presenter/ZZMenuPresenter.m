//
//  ZZMenuPresenter.m
//  Zazo
//

#import "ZZMenuPresenter.h"
#import "ZZMenu.h"

@interface ZZMenuPresenter ()

@end

@implementation ZZMenuPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZMenuViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    [self.userInterface showUsername:[self.interactor username]];
}

#pragma mark - Output




#pragma mark - Module Interface



@end
