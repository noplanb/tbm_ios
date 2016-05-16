//
//  ZZMainModuleInterface.h
//  Zazo
//

@protocol ZZMainModuleInterface <NSObject>

@property (nonatomic, assign) NSUInteger activePageIndex;

- (UIView *)overlayView;

@end
