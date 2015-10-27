//
//  ZZRemoteStorageGeneratorTest.m
//  Zazo
//
//  Created by ANODA on 10/27/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZZRemoteStorageValueGenerator.h"
#import "TBMRemoteStorageHandler.h"
#import "TBMFriend.h"

@interface ZZRemoteStorageGeneratorTest : XCTestCase

@property (nonatomic, strong) TBMFriend* testingFriend;
@property (nonatomic,strong) NSString* videoIdSting;

@end

@implementation ZZRemoteStorageGeneratorTest

- (void)setUp {
    [super setUp];
    
    
    self.testingFriend = [TBMFriend new];
    self.testingFriend.mkey = @"9988mkey";
    self.testingFriend.ckey = @"1234ckey";
    
    self.continueAfterFailure = NO;
    [[[XCUIApplication alloc] init] launch];

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testIncomingVideoFileName
{
    NSString* zInStroageFileName = [ZZRemoteStorageValueGenerator incomingVideoRemoteFilenameWithFriendMkey:self.testingFriend.mkey friendCKey:self.testingFriend.ckey videoId:@"key"];
//    NSString* tbmStorageFileName = [TBMRemoteStorageHandler incomingVideoRemoteFilename:<#(TBMVideo *)#>]

}


@end
