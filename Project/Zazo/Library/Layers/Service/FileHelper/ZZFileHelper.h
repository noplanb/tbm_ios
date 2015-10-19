//
//  ZZFileHelper.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@interface ZZFileHelper : NSObject


#pragma mark - Checks

+ (BOOL)isFileExistsAtURL:(NSURL*)fileURL;
+ (unsigned long long)fileSizeWithURL:(NSURL*)fileURL;
+ (BOOL)isFileValidWithFileURL:(NSURL*)fileURL;


#pragma mark - File Operations

+ (NSURL*)fileURLInDocumentsDirectoryWithName:(NSString*)fileName;
+ (void)deleteFileWithURL:(NSURL*)fileURL;


#pragma mark - Media File

+ (BOOL)isMediaFileCorruptedWithFileUrl:(NSURL*)fileUrl;


#pragma mark - Free Space 

+ (uint64_t)loadFreeDiskspaceValue;

@end
