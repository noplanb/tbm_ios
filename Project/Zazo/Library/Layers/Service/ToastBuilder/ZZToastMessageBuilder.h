//
//  ZZMessageManager.h
//
//  Created by ANODA on 14/12/14.
//
//

@protocol ZZToastMessageBuilderDelegate

@optional
- (void)toastMessageWillShow;
- (void)toastMessageDidShow;
- (void)toastMessageWillDismiss;
- (void)toastMessageDidDismiss;

@end

@interface ZZToastMessageBuilder : NSObject

@property (nonatomic, weak) id<ZZToastMessageBuilderDelegate> delegate;

- (void)showToastWithTitle:(NSString*)title andMessage:(NSString*)message;

@end
