//
//  ZZMainViewInterface.h
//  Zazo
//

@protocol ZZMainViewInterface <NSObject>

@property (nonatomic, assign) NSUInteger activePageIndex;
@property (nonatomic, assign) CGFloat progressBarPosition;
@property (nonatomic, assign) NSUInteger progressBarBadge;

@end
