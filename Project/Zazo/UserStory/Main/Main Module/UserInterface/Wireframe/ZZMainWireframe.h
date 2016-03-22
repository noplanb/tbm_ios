//
//  ZZMainWireframe.h
//  Zazo
//

typedef enum : NSUInteger {
    ZZMainWireframeTabMenu,
    ZZMainWireframeTabGrid,
    ZZMainWireframeTabContacts,
} ZZMainWireframeTab;

@interface ZZMainWireframe : NSObject

- (void)presentMainControllerFromWindow:(UIWindow *)window completion:(ANCodeBlock)completionBlock;
- (void)showTab:(ZZMainWireframeTab)tab;

@end
