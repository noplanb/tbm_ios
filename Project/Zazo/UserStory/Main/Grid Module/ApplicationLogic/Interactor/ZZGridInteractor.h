//
//  ZZGridInteractor.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridInteractorIO.h"

@interface ZZGridInteractor : NSObject <ZZGridInteractorInput>

@property (nonatomic, weak) id<ZZGridInteractorOutput, ZZGridInteractorOutputActionHandler> output;

@end

