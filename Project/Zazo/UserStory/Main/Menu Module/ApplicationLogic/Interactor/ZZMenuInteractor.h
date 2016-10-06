//
//  ZZMenuInteractor.h
//  Zazo
//

#import "ZZMenuInteractorIO.h"
#import "AvatarService.h"

@interface ZZMenuInteractor : NSObject <ZZMenuInteractorInput>

@property (nonatomic, weak) id <ZZMenuInteractorOutput> output;

@end

