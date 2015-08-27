//
// Created by Maksim Bazarov on 30.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMVideoObject.h"

@implementation TBMVideoObject {

}
+ (TBMVideoObject *)makeVideoObjectWithVideoID:(NSString *)videoID status:(NSString *)status {

    if (!videoID) {
        return nil;
    }

    TBMVideoObject *resultObject = [[TBMVideoObject alloc] init];

    resultObject.videoID = videoID;
    resultObject.videoStatus = status ? status : @"-";

    return resultObject;
}

@end