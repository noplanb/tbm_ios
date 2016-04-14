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
    userInterface.activePageIndex = 1;
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

@dynamic progressBarPosition;

- (void)setProgressBarPosition:(CGFloat)progressBarPosition
{
    self.userInterface.progressBarPosition = progressBarPosition;
}

- (CGFloat)progressBarPosition
{
    return self.userInterface.progressBarPosition;
}

@dynamic progressBarBadge;

- (void)setProgressBarBadge:(NSUInteger)progressBarBadge
{
    self.userInterface.progressBarBadge = progressBarBadge;
}

- (NSUInteger)progressBarBadge
{
    return self.userInterface.progressBarBadge;
}

- (UIView *)overlayView
{
    return self.userInterface.view;
}


@end
