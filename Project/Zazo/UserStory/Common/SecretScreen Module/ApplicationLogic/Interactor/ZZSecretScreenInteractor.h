//
//  ZZSecretScreenInteractor.h
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretScreenInteractorIO.h"

@interface ZZSecretScreenInteractor : NSObject <ZZSecretScreenInteractorInput>

@property (nonatomic, weak) id<ZZSecretScreenInteractorOutput> output;

@end

