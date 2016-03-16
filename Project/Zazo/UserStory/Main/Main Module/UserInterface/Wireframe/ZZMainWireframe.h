//
//  ZZMainWireframe.h
//  Zazo
//

@interface ZZMainWireframe : NSObject

- (void)presentMainControllerFromWindow:(UIWindow *)window completion:(ANCodeBlock)completionBlock;
- (void)dismissMainController;

@end
