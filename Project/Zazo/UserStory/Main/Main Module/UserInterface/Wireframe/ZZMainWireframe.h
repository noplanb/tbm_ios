//
//  ZZMainWireframe.h
//  Zazo
//

typedef enum : NSUInteger {
    ZZMainWireframeTabMenu,
    ZZMainWireframeTabGrid,
    ZZMainWireframeTabContacts,
} ZZMainWireframeTab;

@class ANMessageDomainModel;

@interface ZZMainWireframe : NSObject

- (void)presentMainControllerFromWindow:(UIWindow *)window completion:(ANCodeBlock)completionBlock;
- (void)showTab:(ZZMainWireframeTab)tab;

- (void)presentSendFeedbackWithModel:(ANMessageDomainModel*)model;
- (void)presentEditFriendsController;

@end
