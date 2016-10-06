//
//  ZZMenuViewInterface.h
//  Zazo
//

@class ANMemoryStorage;

@protocol ZZMenuViewInterface <NSObject>

- (void)showUsername:(NSString *)username;
- (void)showAvatar:(UIImage *)image;

@property (nonatomic, strong) ANMemoryStorage *storage;

@end
