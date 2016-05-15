//
//  ZZPlayerInteractor.h
//  Zazo
//

#import "ZZPlayerInteractorIO.h"

@interface ZZPlayerInteractor : NSObject <ZZPlayerInteractorInput>

@property (nonatomic, weak) id<ZZPlayerInteractorOutput> output;

@end

