//
//  ZZTabbarVC.h
//  Zazo
//

#import "ZZMainViewInterface.h"
#import "ZZMainModuleInterface.h"

@protocol ZZTabbarViewItem;

@interface ZZTabbarVC : UIViewController <ZZMainViewInterface>

@property (nonatomic, strong) id<ZZMainModuleInterface> eventHandler;

@property (nonatomic, strong) NSArray <UIViewController<ZZTabbarViewItem> *> *viewControllers;

@end
