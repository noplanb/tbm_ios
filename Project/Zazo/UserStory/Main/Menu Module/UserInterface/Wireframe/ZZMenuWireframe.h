//
//  ZZMenuWireframe.h
//  Zazo
//

@class ZZMainWireframe;

@interface ZZMenuWireframe : NSObject

@property (nonatomic, strong, readonly) UIViewController* menuController;
@property (nonatomic, weak) ZZMainWireframe *mainWireframe;

@end
