//
//  ZZMenuPresenter.m
//  Zazo
//

#import "ZZMenuPresenter.h"
#import "ZZMenu.h"
#import "ZZMainWireframe.h"
#import "ZZGridWireframe.h"
#import "ANMemoryStorage.h"
#import "ZZMenuCellModel.h"
#import "ZZGridActionStoredSettings.h"
#import "ZZDeleteFriendsFeatureEventHandler.h"

@interface ZZMenuPresenter ()

@end

@implementation ZZMenuPresenter

- (void)configurePresenterWithUserInterface:(UIViewController <ZZMenuViewInterface> *)userInterface
{
    self.userInterface = userInterface;
    [self.userInterface showUsername:[self.interactor username]];
    self.userInterface.storage = [self _makeStorage];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editFriendsUnlockedNotification:)
                                                 name:ZZFeatureUnlockedNotificationName
                                               object:nil];
}

- (void)editFriendsUnlockedNotification:(NSNotificationCenter *)notification
{
    self.userInterface.storage = [self _makeStorage];
}

- (ANMemoryStorage *)_makeStorage
{
    ANMemoryStorage *storage = [ANMemoryStorage storage];

    ZZMenuCellModel *inviteFriends =
            [ZZMenuCellModel modelWithTitle:@"Invite friends" iconWithImageNamed:@"invite-friends"];

    ZZMenuCellModel *editFriends =
            [ZZMenuCellModel modelWithTitle:@"Edit Zazo friends" iconWithImageNamed:@"edit-friends"];

    ZZMenuCellModel *contacts =
            [ZZMenuCellModel modelWithTitle:@"Contacts" iconWithImageNamed:@"contacts"];

    ZZMenuCellModel *helpFeedback =
            [ZZMenuCellModel modelWithTitle:@"Help & feedback" iconWithImageNamed:@"feedback"];

    inviteFriends.type = ZZMenuItemTypeInviteFriends;
    editFriends.type = ZZMenuItemTypeEditFriends;
    contacts.type = ZZMenuItemTypeContacts;
    helpFeedback.type = ZZMenuItemTypeHelp;

    [storage addItem:inviteFriends toSection:0];

    if ([ZZGridActionStoredSettings shared].deleteFriendFeatureEnabled)
    {
        [storage addItem:editFriends toSection:0];
    }

    [storage addItem:contacts toSection:0];
    [storage addItem:helpFeedback toSection:0];
    
    
    BOOL showDebugRow = NO;
    
#ifdef DEBUG
#ifndef MAKING_SCREENSHOTS

    showDebugRow = YES;

#endif
#endif

    if (showDebugRow)
    {
        ZZMenuCellModel *secretScreen =
                [ZZMenuCellModel modelWithTitle:@"Secret screen" iconWithImageNamed:@"settings"];

        secretScreen.type = ZZMenuItemTypeSecretScreen;
        [storage addItem:secretScreen toSection:0];
    }
    
    return storage;
}

- (void)titleTap
{
    static NSUInteger tapCount;
    
    tapCount++;
    
    if (tapCount > 4)
    {
        [self.wireframe showSecretScreen];
    }
}

#pragma mark - Output

- (void)feedbackModelLoadedSuccessfully:(ANMessageDomainModel *)model
{
    [self.wireframe.mainWireframe presentSendFeedbackWithModel:model];
}

#pragma mark - Module Interface

- (void)eventDidTapItemWithType:(ZZMenuItemType)type
{
    switch (type)
    {
        case ZZMenuItemTypeContacts:
            self.wireframe.mainWireframe.activeTab = ZZMainWireframeTabContacts;
            break;
        case ZZMenuItemTypeInviteFriends:
            self.wireframe.mainWireframe.activeTab = ZZMainWireframeTabContacts;
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
