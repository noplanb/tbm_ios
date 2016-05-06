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
    ZZMenuItemTypeSecretScreen
} ZZMenuItemType;

@protocol ZZMenuModuleInterface <NSObject>

- (void)eventDidTapItemWithType:(ZZMenuItemType)type;
- (void)titleTap;

@end
