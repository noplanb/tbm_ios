//
//  ZZAvatarVC.h
//  Zazo
//

#import "ZZAvatarViewInterface.h"
#import "ZZAvatarModuleInterface.h"

@interface ZZAvatarVC : UIViewController <ZZAvatarViewInterface>

@property (nonatomic, strong) id<ZZAvatarModuleInterface> eventHandler;

@end
