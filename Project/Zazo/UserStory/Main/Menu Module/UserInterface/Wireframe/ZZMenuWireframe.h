//
//  ZZMenuWireframe.h
//  Zazo
//

@class ZZMainWireframe;
@class ANMessageDomainModel;

@interface ZZMenuWireframe : NSObject

@property (nonatomic, strong, readonly) UIViewController* menuController;
@property (nonatomic, weak) ZZMainWireframe *mainWireframe;

- (void)presentSendFeedbackWithModel:(ANMessageDomainModel*)model;
- (void)presentEditFriendsController;

@end
