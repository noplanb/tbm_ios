//
//  ZZSecretInteractor.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretInteractorIO.h"

@interface ZZSecretInteractor : NSObject <ZZSecretInteractorInput>

@property (nonatomic, weak) id <ZZSecretInteractorOutput> output;

@end

