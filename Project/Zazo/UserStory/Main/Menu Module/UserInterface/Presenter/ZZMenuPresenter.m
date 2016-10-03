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
#import "ZZVideoRecorder.h"

@interface ZZMenuPresenter ()

@property (nonatomic, strong) PhotoLibraryHelper *photoHelper;

@end

typedef NS_ENUM(NSUInteger, ZZAvatarChangeMenuAction) {
    ZZAvatarChangeMenuActionCamera,
    ZZAvatarChangeMenuActionLibrary,
    ZZAvatarChangeMenuActionRemove,
    ZZAvatarChangeMenuActionCancel
};

typedef void(^ZZAvatarChangeMenuActionHandler)(UIAlertAction *action);

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
    
    self.photoHelper = [PhotoLibraryHelper new];
    
    [self.interactor checkAvatarForUpdate];
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

- (void)didTapUsername;
{
    static NSUInteger tapCount;
    
    tapCount++;
    
    if (tapCount > 4)
    {
        [self.wireframe showSecretScreen];
    }
}

- (void)didTapAvatar
{
    UIAlertControllerStyle style =
        UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ?
        UIAlertControllerStyleAlert :
        UIAlertControllerStyleActionSheet;
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:@"Set avatar"
                                        message:nil
                                 preferredStyle:style];
    
    
    
    UIAlertAction *takeFromCamera =
        [UIAlertAction actionWithTitle:@"Take from the camera"
                                 style:UIAlertActionStyleDefault
                               handler:[self handlerForAction:ZZAvatarChangeMenuActionCamera]];
    
    UIAlertAction *pickFromLibrary =
        [UIAlertAction actionWithTitle:@"Pick from the library"
                                 style:UIAlertActionStyleDefault
                               handler:[self handlerForAction:ZZAvatarChangeMenuActionLibrary]];
    
    UIAlertAction *removeAvatar =
        [UIAlertAction actionWithTitle:@"Remove avatar"
                                 style:UIAlertActionStyleDestructive
                               handler:[self handlerForAction:ZZAvatarChangeMenuActionRemove]];
    
    UIAlertAction *cancel =
        [UIAlertAction actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleCancel
                               handler:[self handlerForAction:ZZAvatarChangeMenuActionCancel]];
    
    [alertController addAction:takeFromCamera];
    [alertController addAction:pickFromLibrary];
    
    if ([self.interactor hasAvatar])
    {
        [alertController addAction:removeAvatar];
    }
    
    [alertController addAction:cancel];
    

    
    [self.userInterface presentViewController:alertController
                                     animated:YES
                                   completion:nil];
}

- (ZZAvatarChangeMenuActionHandler)handlerForAction:(ZZAvatarChangeMenuAction)action
{
    void (^ handler)(UIAlertAction *action) = ^(UIAlertAction *alertAction){
        switch (action) {
            case ZZAvatarChangeMenuActionCamera:
                [self didPickCameraMenuItem];
            break;
            case ZZAvatarChangeMenuActionLibrary:
                [self didPickLibraryMenuItem];
            break;
            case ZZAvatarChangeMenuActionRemove:
                [self didPickRemoveAvatarMenuItem];
            break;
            default:
                break;
        }
    };
    
    return handler;
}

- (void)didPickCameraMenuItem
{
    [[ZZVideoRecorder shared] stopPreview];
    [self.photoHelper presentCameraFrom:self.userInterface with:^(UIImage * _Nullable image) {
        [[ZZVideoRecorder shared] startPreview];
        [self updateAvatarWithImage:image];
    }];
}

- (void)didPickLibraryMenuItem
{
    [self.photoHelper presentLibraryFrom:self.userInterface with:^(UIImage * _Nullable image) {
        [self updateAvatarWithImage:image];
    }];
}

- (void)updateAvatarWithImage:(UIImage *)image
{
    if (!image)
    {
        return;
    }
    
    [self.userInterface showLoading:YES];
    [self.interactor uploadAvatar:image completion:^(NSError *error) {
        
        [self.userInterface showLoading:NO];

        if (error)
        {
            [self.userInterface askForRetry:error.localizedDescription
                                 completion:^(BOOL confirmed) {
                if (confirmed)
                {
                    [self updateAvatarWithImage:image];
                }
            }];
            
            return;
        }
        
        [self currentAvatarWasChanged:image];
    }];
}

- (void)didPickRemoveAvatarMenuItem
{
    [self.userInterface showLoading:YES];
    [self.interactor removeAvatarCompletion:^(NSError *error) {
        
        [self.userInterface showLoading:NO];

        if (error)
        {
            [self.userInterface askForRetry:error.localizedDescription
                                 completion:^(BOOL confirmed) {
                if (confirmed)
                {
                    [self didPickRemoveAvatarMenuItem];
                }
            }];
            
            return;
        }
    }];
}

#pragma mark - Output

- (void)feedbackModelLoadedSuccessfully:(ANMessageDomainModel *)model
{
    [self.wireframe.mainWireframe presentSendFeedbackWithModel:model];
}

- (void)avatarUpdateDidComplete
{
}

- (void)avatarUpdateDidFail
{
}

- (void)currentAvatarWasChanged:(UIImage *)avatar
{
    [self.userInterface showAvatar:avatar];
}

- (void)avatarFetchDidComplete
{
    [self.userInterface showLoading:NO];
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
