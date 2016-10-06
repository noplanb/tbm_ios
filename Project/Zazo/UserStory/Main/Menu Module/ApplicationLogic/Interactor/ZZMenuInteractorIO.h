//
//  ZZMenuInteractorIO.h
//  Zazo
//

@class ANMessageDomainModel;

@protocol ZZMenuInteractorInput <NSObject>

- (NSString *)username;
- (void)loadFeedbackModel;

@end


@protocol ZZMenuInteractorOutput <NSObject>

- (void)feedbackModelLoadedSuccessfully:(ANMessageDomainModel *)model;

@end
