//
//  ZZMainWireframe.h
//  Zazo
//

typedef enum : NSUInteger
{
    ZZMainWireframeTabMenu,
    ZZMainWireframeTabGrid,
    ZZMainWireframeTabContacts,
} ZZMainWireframeTab;

@class ANMessageDomainModel, ZZGridWireframe, ZZContactsWireframe, ZZMenuWireframe;
@protocol ZZMainModuleInterface;

@interface ZZMainWireframe : NSObject

@property (nonatomic, assign) ZZMainWireframeTab activeTab;

@property (nonatomic, strong) ZZGridWireframe *gridWireframe;
@property (nonatomic, strong) ZZContactsWireframe *contactsWireframe;
@property (nonatomic, strong) ZZMenuWireframe *menuWireframe;

- (void)presentMainControllerFromWindow:(UIWindow *)window completion:(ANCodeBlock)completionBlock;
- (void)presentSendFeedbackWithModel:(ANMessageDomainModel *)model;
- (void)presentEditFriendsController;

- (void)popToRootVC;

@property (nonatomic, readonly) id <ZZMainModuleInterface> moduleInterface;

@end
