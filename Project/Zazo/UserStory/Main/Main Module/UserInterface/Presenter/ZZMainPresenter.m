//
//  ZZMainPresenter.m
//  Zazo
//

#import "ZZMainPresenter.h"
#import "ZZMain.h"

@interface ZZMainPresenter ()

@end

@implementation ZZMainPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZMainViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    userInterface.activePageIndex = 0;
}

#pragma mark - Output




#pragma mark - Module Interface

@dynamic activePageIndex;

- (NSUInteger)activePageIndex
{
    return self.userInterface.activePageIndex;
}

- (void)setActivePageIndex:(NSUInteger)activePageIndex
{
    self.userInterface.activePageIndex = activePageIndex;
}


@end
