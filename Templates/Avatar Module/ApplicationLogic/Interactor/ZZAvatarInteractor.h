//
//  ZZAvatarInteractor.h
//  Zazo
//

#import "ZZAvatarInteractorIO.h"

@interface ZZAvatarInteractor : NSObject <ZZAvatarInteractorInput>

@property (nonatomic, weak) id<ZZAvatarInteractorOutput> output;

@end

