//
//  ZZMenuModuleInterface.h
//  Zazo
//

typedef enum : NSUInteger
{
    ZZMenuItemTypeInviteFriends,
    ZZMenuItemTypeEditFriends,
    ZZMenuItemTypeContacts,
    ZZMenuItemTypeHelp,
    ZZMenuItemTypeSecretScreen,
    ZZMenuItemTypeUseAvatar,
    ZZMenuItemTypeUseLastFrame,
} ZZMenuItemType;

@protocol ZZMenuModuleInterface <NSObject>

- (void)eventDidTapItemWithType:(ZZMenuItemType)type;
- (void)didTapUsername;
- (void)didTapAvatar;

@end
