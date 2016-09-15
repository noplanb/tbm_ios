//
//  ZZMenuInteractor.h
//  Zazo
//

#import "ZZMenuInteractorIO.h"
#import "AvatarService.h"

@interface ZZMenuInteractor : NSObject <ZZMenuInteractorInput, AvatarUpdateServiceDelegate>

@property (nonatomic, strong) AvatarUpdateService *updateService;
@property (nonatomic, strong) AvatarStorageService *storageService;
@property (nonatomic, strong) id<LegacyAvatarService> networkService;

@property (nonatomic, weak) id <ZZMenuInteractorOutput> output;

@end

