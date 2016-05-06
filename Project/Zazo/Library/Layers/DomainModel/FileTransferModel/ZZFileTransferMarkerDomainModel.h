//
//  ZZFileTransferMarkerDomainModel.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class FEMObjectMapping;

extern const struct ZZFileTransferMarkerDomainModelAttributes
{
    __unsafe_unretained NSString *friendID;
    __unsafe_unretained NSString *videoID;
    __unsafe_unretained NSString *isUpload;
} ZZFileTransferMarkerDomainModelAttributes;

@interface ZZFileTransferMarkerDomainModel : NSObject

@property (nonatomic, copy) NSString *friendID;
@property (nonatomic, copy) NSString *videoID;
@property (nonatomic, assign) BOOL isUpload;

+ (instancetype)modelWithEncodedMarker:(NSString *)marker;

+ (FEMObjectMapping *)mapping;

- (NSString *)markerValue;

@end
