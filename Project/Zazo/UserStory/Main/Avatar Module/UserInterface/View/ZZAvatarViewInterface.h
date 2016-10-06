//
//  ZZAvatarViewInterface.h
//  Zazo
//

@class ANMemoryStorage;

@protocol ZZAvatarViewInterface <NSObject>

- (void)askForRetry:(NSString *)message completion:(void (^)(BOOL confirmed))completion;
- (void)showAvatar:(UIImage *)image;
- (void)showLoading:(BOOL)visible;

@property (nonatomic, strong) ANMemoryStorage *storage;


@end
