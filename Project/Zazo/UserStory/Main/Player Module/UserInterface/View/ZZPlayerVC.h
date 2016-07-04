//
//  ZZPlayerVC.h
//  Zazo
//

#import "ZZPlayerViewInterface.h"
#import "ZZPlayerModuleInterface.h"

@interface ZZPlayerVC : UIViewController <ZZPlayerViewInterface>

@property (nonatomic, strong) id<ZZPlayerModuleInterface, PlaybackIndicatorDelegate> eventHandler;

@end
