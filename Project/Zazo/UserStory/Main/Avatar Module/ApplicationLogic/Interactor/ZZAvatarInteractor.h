//
//  ZZAvatarInteractor.h
//  Zazo
//

#import "ZZAvatarInteractorIO.h"

@interface ZZAvatarInteractor : NSObject <ZZAvatarInteractorInput, AvatarUpdateServiceDelegate>

@property (nonatomic, strong) AvatarUpdateService *updateService;
@property (nonatomic, strong) AvatarStorageService *storageService;
@property (nonatomic, strong) id<LegacyAvatarService> networkService;

@property (nonatomic, weak) id<ZZAvatarInteractorOutput> output;

@end

