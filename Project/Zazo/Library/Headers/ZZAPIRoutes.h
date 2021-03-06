//
//  ZZAPIRoutes.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZStoredSettingsManager.h"

#pragma mark - API Routes settings

NSString *APIBaseURL();

#pragma mark - Authorization

static NSString *const kApiAuthRegistration = @"reg/reg";
static NSString *const kApiAuthVerifyCode = @"reg/verify_code";


#pragma mark - Push Notifications

static NSString *const kApiSavePushToken = @"notification/set_push_token";


#pragma mark - Videos

static NSString *const kApiDeleteVideo = @"videos/delete";
static NSString *const kApiNotificationVideoReceived = @"notification/send_video_received";
static NSString *const kApiNotificationVideoStatusUpdate = @"notification/send_video_status_update";


#pragma mark - Friends

static NSString *const kApiLoadFriends = @"reg/get_friends";
static NSString *const kApiLoadFriendProfile = @"invitation/invite";
static NSString *const kApiUpdateFriendProfile = @"invitation/update_friend";
static NSString *const kApiUserHapApp = @"invitation/has_app";
static NSString *const kApiChangeFriendVisibilityStatus = @"connection/set_visibility";

#pragma mark - Polling
static NSString *const kApiGetAllIncomingVideoIds = @"kvstore/received_videos";
static NSString *const kApiGetAllOutgoingVideoStatus = @"kvstore/video_status";


#pragma mark - Remote Logging

static NSString *const kApiLogMessage = @"dispatch/post_dispatch";

static NSString *const kApiCheckApplicationVersion = @"version/check_compatibility";
//static NSString *const kApiS3Credentials = @"s3_credentials/info";


#pragma mark - Key Store

static NSString *const kApiKeyLoad = @"kvstore/get_all";
static NSString *const kApiKeyDelete = @"kvstore/delete";
static NSString *const kApiKeyUpdate = @"kvstore/set";


#pragma mark - Static

static NSString *const kInviteFriendBaseURL = @"zazoapp.com/c/";


