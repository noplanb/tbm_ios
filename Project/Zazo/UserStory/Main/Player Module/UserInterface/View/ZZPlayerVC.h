//
//  ZZPlayerVC.h
//  Zazo
//

#import "ZZPlayerViewInterface.h"
#import "ZZPlayerModuleInterface.h"

@interface ZZPlayerVC : UIViewController <ZZPlayerViewInterface>

@property (nonatomic, weak) id<ZZPlayerModuleInterface> eventHandler;

@end
