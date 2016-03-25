//
//  ZZMenuVC.h
//  Zazo
//

#import "ZZMenuViewInterface.h"
#import "ZZMenuModuleInterface.h"

@interface ZZMenuVC : UIViewController <ZZMenuViewInterface>

@property (nonatomic, strong) id<ZZMenuModuleInterface> eventHandler;

@end
