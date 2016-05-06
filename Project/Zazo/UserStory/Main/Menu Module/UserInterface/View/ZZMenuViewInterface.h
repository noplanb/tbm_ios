//
//  ZZMenuViewInterface.h
//  Zazo
//

@class ANMemoryStorage;

@protocol ZZMenuViewInterface <NSObject>

- (void)showUsername:(NSString *)username;

@property (nonatomic, strong) ANMemoryStorage *storage;

@end
