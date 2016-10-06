//
//  ZZMenuModuleInterface.h
//  Zazo
//

#import "ZZMenuItemTypes.h"

@protocol ZZMenuModuleInterface <NSObject>

- (void)eventDidTapItemWithType:(ZZMenuItemType)type;
- (void)didTapUsername;
- (void)didTapAvatar;

@end
