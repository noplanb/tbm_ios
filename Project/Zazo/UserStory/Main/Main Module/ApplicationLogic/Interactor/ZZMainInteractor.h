//
//  ZZMainInteractor.h
//  Zazo
//

#import "ZZMainInteractorIO.h"

@interface ZZMainInteractor : NSObject <ZZMainInteractorInput>

@property (nonatomic, weak) id<ZZMainInteractorOutput> output;

@end

