//
//  ZZMainModuleInterface.h
//  Zazo
//

@protocol ZZMainModuleInterface <NSObject>

@property (nonatomic, assign) NSUInteger activePageIndex;
@property (nonatomic, assign) CGFloat progressBarPosition;
@property (nonatomic, assign) NSUInteger progressBarBadge;

@end
