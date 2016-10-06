//
//  ZZAvatarPresenter.m
//  Zazo
//

#import "ZZAvatarPresenter.h"
#import "ZZAvatar.h"
#import "ANMemoryStorage.h"
#import "ZZVideoRecorder.h"
#import "ZZMenuCellModel.h"

typedef void(^ZZAvatarChangeMenuActionHandler)(UIAlertAction *action);

typedef NS_ENUM(NSUInteger, ZZAvatarChangeMenuAction) {
    ZZAvatarChangeMenuActionCamera,
    ZZAvatarChangeMenuActionLibrary,
    ZZAvatarChangeMenuActionRemove,
    ZZAvatarChangeMenuActionCancel
};

@interface ZZAvatarPresenter ()

@property (nonatomic, strong) PhotoLibraryHelper *photoHelper;

@end

@implementation ZZAvatarPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZAvatarViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    self.photoHelper = [PhotoLibraryHelper new];

    [self.interactor checkAvatarForUpdate];
    self.userInterface.storage = [self _makeStorage];
}

#pragma mark - Output

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

- (ANMemoryStorage *)_makeStorage
{
    ANMemoryStorage *storage = [ANMemoryStorage storage];
    
    ZZMenuCellModel *inviteFriends =
    [ZZMenuCellModel modelWithTitle:@"Use profile photo" iconWithImageNamed:@"checkmark"];
    
    ZZMenuCellModel *editFriends =
    [ZZMenuCellModel modelWithTitle:@"Use last zazo" iconWithImageNamed:@"no-checkmark"];
    
    inviteFriends.type = ZZMenuItemTypeInviteFriends;
    editFriends.type = ZZMenuItemTypeEditFriends;
    
    [storage addItem:inviteFriends toSection:0];
    [storage addItem:editFriends toSection:0];    
    
    return storage;
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



@end
