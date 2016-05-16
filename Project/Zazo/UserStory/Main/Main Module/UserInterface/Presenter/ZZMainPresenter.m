//
//  ZZMainPresenter.m
//  Zazo
//

#import "ZZMainPresenter.h"
#import "ZZMain.h"

@interface ZZMainPresenter ()

@end

@implementation ZZMainPresenter

- (void)configurePresenterWithUserInterface:(UIViewController <ZZMainViewInterface> *)userInterface
{
    self.userInterface = userInterface;
    userInterface.activePageIndex = 1;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationDidEnterBackgroundNotification)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)_applicationDidEnterBackgroundNotification
{
    [self.wireframe showTab:ZZMainWireframeTabGrid];
    [self.wireframe popToRootVC];
}

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

- (UIView *)overlayView
{
    return self.userInterface.view;
}


@end
