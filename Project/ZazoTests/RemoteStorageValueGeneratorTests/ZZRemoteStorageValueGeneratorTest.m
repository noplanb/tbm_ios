//
//  ZZRemoteStorageValueGeneratorTest.m
//  Zazo
//
//  Created by ANODA on 10/28/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZZRemoteStorageValueGenerator.h"


@interface ZZRemoteStorageValueGeneratorTest : XCTestCase

@property (nonatomic, strong) NSString* friendMkey;
@property (nonatomic, strong) NSString* friendCkey;
@property (nonatomic, strong) NSString* videoId;

@property (nonatomic, strong) NSString* expectedIncomingVideoFileName;
@property (nonatomic, strong) NSString* expectedOutgoingVideoFileName;

@property (nonatomic, strong) NSString* expectedIncomingVideoId;
@property (nonatomic, strong) NSString* expectedOutgoingVideoId;

@property (nonatomic, strong) NSString* expectedIncomingVideoStatus;
@property (nonatomic, strong) NSString* expectedOutgoingVideoStatus;

@end

@implementation ZZRemoteStorageValueGeneratorTest

- (void)setUp {
    [super setUp];
    
    self.friendMkey = @"hClwSlTC91iZAEUs45wW";
    self.friendCkey = @"1422_1157_JA87n5OzdAWO49liMzOl";
    self.videoId = @"1446019574374";
    
    //expected values:
    self.expectedIncomingVideoFileName = @"hClwSlTC91iZAEUs45wW-zUE8XKT8jBGLyXxjgnOG-ca66c5d6978d923a8b129f91544acde3";
    self.expectedOutgoingVideoFileName = @"zUE8XKT8jBGLyXxjgnOG-hClwSlTC91iZAEUs45wW-ca66c5d6978d923a8b129f91544acde3";
    
    self.expectedIncomingVideoId = @"hClwSlTC91iZAEUs45wW-zUE8XKT8jBGLyXxjgnOG-8e6e284ddb25c6bb1c420f72e811af5b-VideoIdKVKey";
    self.expectedOutgoingVideoId = @"zUE8XKT8jBGLyXxjgnOG-hClwSlTC91iZAEUs45wW-cb7ce78626a564fd782a1030433c80f1-VideoIdKVKey";
    
    self.expectedIncomingVideoStatus = @"hClwSlTC91iZAEUs45wW-zUE8XKT8jBGLyXxjgnOG-8e6e284ddb25c6bb1c420f72e811af5b-VideoStatusKVKey";
    self.expectedOutgoingVideoStatus = @"zUE8XKT8jBGLyXxjgnOG-hClwSlTC91iZAEUs45wW-cb7ce78626a564fd782a1030433c80f1-VideoStatusKVKey";
}

- (void)tearDown {
    [super tearDown];
}


#pragma mark - FileName Tests

- (void)testIncomingVideoRemoteFileName
{
    NSString* incomingVideoFileName = [ZZRemoteStorageValueGenerator incomingVideoRemoteFilenameWithFriendMkey:self.friendMkey
                                                                                                    friendCKey:self.friendCkey
                                                                                                       videoID:self.videoId];
    
    XCTAssertEqualObjects(incomingVideoFileName, self.expectedIncomingVideoFileName,
                          @"remote icoming video file name:%@ not equal expected: %@",
                          incomingVideoFileName, self.expectedIncomingVideoFileName);

}

- (void)testOutgoingVideoRemoteFileName
{
    NSString* outgoingVideoFilename = [ZZRemoteStorageValueGenerator outgoingVideoRemoteFilenameWithFriendMkey:self.friendMkey
                                                                                                    friendCKey:self.friendCkey
                                                                                                       videoID:self.videoId];
    XCTAssertEqualObjects(outgoingVideoFilename, self.expectedOutgoingVideoFileName,
                          @"remote outgoing video file name:%@ not equal expected: %@",
                          outgoingVideoFilename, self.expectedOutgoingVideoFileName);

}


#pragma mark - Video Id Tests

- (void)testIncomingVideoId
{
    NSString* incomingVideoId = [ZZRemoteStorageValueGenerator incomingVideoIDRemoteKVKeyWithFriendMKey:self.friendMkey
                                                                                             friendCKey:self.friendCkey];
    XCTAssertEqualObjects(incomingVideoId, self.expectedIncomingVideoId,
                          @"incoming video id: %@ not equal expected: %@",
                          incomingVideoId, self.expectedIncomingVideoId);

}

- (void)testOutgoingVideoId
{
    NSString* outgoingVideoId = [ZZRemoteStorageValueGenerator outgoingVideoIDRemoteKVWithFriendMKey:self.friendMkey
                                                                                          friendCKey:self.friendCkey];
    
    XCTAssertEqualObjects(outgoingVideoId, self.expectedOutgoingVideoId,
                          @"outgoing video id:%@ not equal expected: %@",
                          outgoingVideoId, self.expectedOutgoingVideoId);

}


#pragma mark - Video Status Test

- (void)testIncomingVideoStatus
{
    NSString* incomingVideoStatus = [ZZRemoteStorageValueGenerator incomingVideoStatusRemoteKVKeyWithFriendMKey:self.friendMkey
                                                                                                     friendCKey:self.friendCkey];
    
    XCTAssertEqualObjects(incomingVideoStatus, self.expectedIncomingVideoStatus,
                          @"incoming video status:%@ not equal expected: %@",
                          incomingVideoStatus, self.expectedIncomingVideoStatus);

}

- (void)testOutgoingVideoStatus
{
    NSString* outgoingVideoStatus = [ZZRemoteStorageValueGenerator outgoingVideoStatusRemoteKVKeyWithFriendMKey:self.friendMkey
                                                                                                     friendCKey:self.friendCkey];
    
    XCTAssertEqualObjects(outgoingVideoStatus, self.expectedOutgoingVideoStatus,
                          @"outgoing video status:%@ not equal expected: %@",
                          outgoingVideoStatus, self.expectedOutgoingVideoStatus);
}


@end
