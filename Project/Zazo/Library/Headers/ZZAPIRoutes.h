//
//  ZZAPIRoutes.h
//  Zazo
//
//  Created by Oleg Panforov on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//


#pragma mark - API Routes settings

static NSString* const kApiBaseURL = @"http://prod.zazoapp.com/";


#pragma mark - Authorization

static NSString* const kApiAuthRegistration = @"reg/reg";
static NSString* const kApiAuthVerifyCode = @"reg/verify_code";
static NSString* const kApiAuthDebugUser = @"reg/debug_get_user"; //TODO: debugUser?


#pragma mark - Push Notifications

static NSString* const kApiSavePushToken = @"notification/set_push_token";


#pragma mark - Videos

static NSString* const kApiDeleteVideo = @"videos/delete";
static NSString* const kApiNotificationVideoReceived = @"notification/send_video_received";
static NSString* const kApiNotificationVideoStatusUpdate = @"notification/send_video_status_update";



static NSString* const kApiCheckIsFriendHasApp = @"invitation/has_app";

static NSString* const kApiLoadFriends = @"reg/get_friends";
static NSString* const kApiLoadFriendProfile = @"invitation/invite";


#pragma mark - Remote Logging

static NSString* const kApiLogMessage = @"dispatch/post_dispatch";

static NSString* const kApiCheckApplicationVersion = @"version/check_compatibility";
static NSString* const kApiS3Credentials = @"s3_credentials/info";