//
//  ZZMenuViewInterface.h
//  Zazo
//

@class ANMemoryStorage;

@protocol ZZMenuViewInterface <NSObject>

- (void)showUsername:(NSString *)username;
- (void)showAvatar:(UIImage *)image;
- (void)showLoading:(BOOL)visible;

- (void)askForRetry:(NSString *)message completion:(void (^)(BOOL confirmed))completion;

@property (nonatomic, strong) ANMemoryStorage *storage;

@end
