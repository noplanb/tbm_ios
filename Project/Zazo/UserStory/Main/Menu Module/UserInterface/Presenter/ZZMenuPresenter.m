//
//  ZZMenuPresenter.m
//  Zazo
//

#import "ZZMenuPresenter.h"
#import "ZZMenu.h"
#import "ZZMainWireframe.h"

@interface ZZMenuPresenter ()

@end

@implementation ZZMenuPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZMenuViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    [self.userInterface showUsername:[self.interactor username]];
}

#pragma mark - Output

- (void)feedbackModelLoadedSuccessfully:(ANMessageDomainModel*)model
{
    [self.wireframe.mainWireframe presentSendFeedbackWithModel:model];
}


#pragma mark - Module Interface

- (void)eventDidTapItemWithType:(ZZMenuItemType)type
{
    switch (type)
    {
        case ZZMenuItemTypeContacts:
            [self.wireframe.mainWireframe showTab:ZZMainWireframeTabContacts];
            break;
        case ZZMenuItemTypeInviteFriends:
            [self.wireframe.mainWireframe showTab:ZZMainWireframeTabContacts];
            break;

        case ZZMenuItemTypeEditFriends:
            [self.wireframe.mainWireframe presentEditFriendsController];
            break;

        case ZZMenuItemTypeHelp:
            [self.interactor loadFeedbackModel];
            break;

        case ZZMenuItemTypeSecretScreen:
            [self.wireframe showSecretScreen];
            break;

        default:
            break;
    }

}


@end
