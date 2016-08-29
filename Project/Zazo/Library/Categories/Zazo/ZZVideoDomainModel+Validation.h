//
//  ZZVideoDomainModel+Validation.h
//  Zazo
//
//  Created by Rinat on 29/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZVideoDomainModel.h"

typedef void(^ZZValidationBlock)(BOOL isValid);

@interface ZZVideoDomainModel (Validation)

- (BOOL)isValidVideo;

@end
