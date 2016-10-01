//
//  ZZMenuViewInterface.h
//  Zazo
//

@class ANMemoryStorage;

@protocol ZZMenuViewInterface <NSObject>

- (void)showUsername:(NSString *)username;
- (void)showAvatar:(UIImage *)image;
- (void)showLoading:(BOOL)visible;

@property (nonatomic, strong) ANMemoryStorage *storage;

@end
