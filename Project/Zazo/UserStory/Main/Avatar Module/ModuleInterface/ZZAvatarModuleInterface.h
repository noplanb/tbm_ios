//
//  ZZAvatarModuleInterface.h
//  Zazo
//

#import "ZZMenuItemTypes.h"

@protocol ZZAvatarModuleInterface <NSObject>

- (void)didTapAvatar;
- (void)eventDidTapItemWithType:(ZZMenuItemType)type;

@end
