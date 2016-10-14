//
//  ZZAvatarWireframe.h
//  Zazo
//

@protocol ZZAvatarModuleDelegate;

@interface ZZAvatarWireframe : NSObject

- (void)presentAvatarControllerFromNavigationController:(UINavigationController *)nc
                                               delegate:(id<ZZAvatarModuleDelegate>)delegate;
- (void)dismissAvatarController;

@end
