//
//  TBMVideoProcessor.h
//  Zazo
//
//  Created by Sani Elfishawy on 4/11/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

extern NSString* const TBMVideoProcessorDidFinishProcessing;
extern NSString* const TBMVideoProcessorDidFail;

@interface TBMVideoProcessor : NSObject

- (void)processVideoWithUrl:(NSURL *)url;

@end
