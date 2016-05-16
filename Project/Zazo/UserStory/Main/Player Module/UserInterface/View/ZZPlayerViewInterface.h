//
//  ZZPlayerViewInterface.h
//  Zazo
//

@class AVPlayerViewController;

@protocol ZZPlayerViewInterface <NSObject>

@property (nonatomic, weak) AVPlayerViewController *playerController;
@property (nonatomic, assign) CGRect initialPlayerFrame;

@end
