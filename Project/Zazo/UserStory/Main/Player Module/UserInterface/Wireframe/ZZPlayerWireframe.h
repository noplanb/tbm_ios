//
//  ZZPlayerWireframe.h
//  Zazo
//

#import "ZZPlayerPresenter.h"
#import "ZZPlayerModuleDelegate.h"
#import "ZZPlayerModuleInterface.h"

@interface ZZPlayerWireframe : NSObject

- (instancetype)initWithVC:(UIViewController *)VC;

@property (nonatomic, weak, readonly) id<ZZPlayerModuleInterface> player;
@property (nonatomic, weak) id<ZZPlayerModuleDelegate> delegate;
@property (nonatomic, assign) BOOL playerVisible;

@end
