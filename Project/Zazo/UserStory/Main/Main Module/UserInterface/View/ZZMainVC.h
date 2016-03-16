//
//  ZZMainVC.h
//  Zazo
//

#import "ZZMainViewInterface.h"
#import "ZZMainModuleInterface.h"

@interface ZZMainVC : UIViewController <ZZMainViewInterface>

@property (nonatomic, strong) id<ZZMainModuleInterface> eventHandler;

@end
