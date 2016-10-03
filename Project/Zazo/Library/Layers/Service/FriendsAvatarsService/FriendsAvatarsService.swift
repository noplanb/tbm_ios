//
//  FriendsAvatarsService.swift
//  Zazo
//
//  Created by Rinat on 01/10/2016.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import ReactiveCocoa
import AWSS3

@objc protocol FriendsAvatarsServiceDelegate: NSObjectProtocol {
    func didDownloadAvatar(forFriend friendModel: ZZFriendDomainModel)
}

@objc class FriendsAvatarsService: NSObject, ZZRootStateObserverDelegate {
    
    weak var delegate: FriendsAvatarsServiceDelegate?
    typealias ImageSignal = SignalProducer<UIImage, Error>
    
    var downloads = [String: AWSTask]()
    
    enum Error: ErrorType {
        case NoSavedFileError
        case NoSuchFriend
        case InvalidS3Credentials
        case DownloadError
    }
    
    @objc func handleEvent(event: ZZRootStateObserverEvents, notificationObject: AnyObject!) {
        
        guard event == .EventAvatarChanged else {
            return
        }
        
        guard let friendModel = notificationObject as? ZZFriendDomainModel else {
            return
        }
        
        updateAvatar(forFriend: friendModel)
    }
    
    func deleteAvatar(ofFriend friendModel: ZZFriendDomainModel) {
        ZZFriendDataUpdater.updateFriendWithID(friendModel.idTbm, setAvatar: nil)
        ZZFriendDataUpdater.updateFriendWithID(friendModel.idTbm, setAvatarTimestamp: 0)
        self.delegate?.didDownloadAvatar(forFriend: friendModel)
    }
    
    func avatarForFriend(forFriend friendModel: ZZFriendDomainModel) -> UIImage? {
    
        guard friendModel.avatarTimestamp > 0 else {
            return nil
        }
        
        let avatar = ZZFriendDataProvider.avatarOfFriendWithID(friendModel.idTbm)
        
        if (avatar == nil) {
            updateAvatar(forFriend: friendModel)
        }
        
        return avatar
    }
    
    func updateAvatar(forFriend friendModel: ZZFriendDomainModel) {
        
        guard friendModel.avatarTimestamp > 0 else {
            deleteAvatar(ofFriend: friendModel)
            return
        }
        
        let service = AWSS3.S3ForKey(ZZCredentialsTypeAvatar)
        let key = "\(friendModel.mKey)_\(Int(friendModel.avatarTimestamp))"
        
        guard let credentialsKeys = ZZKeychainDataProvider.loadCredentialsOfType(ZZCredentialsTypeAvatar) else {
            return
        }
        
        let request = AWSS3GetObjectRequest()
        request.key = key
        request.bucket = credentialsKeys.bucket
    
        if let task = downloads[key] {
            if !task.cancelled || !task.completed {
                return
            }
        }
    
        let task = service.getObject(request)
        downloads[key] = task        
        task.continueWithBlock({ (task) -> AnyObject? in
            
            guard task.error == nil else {
                return nil
            }
            
            guard let result = task.result as? AWSS3GetObjectOutput else {
                return nil
            }
            
            guard let data = result.body as? NSData else {
                return nil
            }
            
            guard let image = UIImage(data: data) else {
                return nil
            }
            
            ZZFriendDataUpdater.updateFriendWithID(friendModel.idTbm, setAvatar: image)
            ZZFriendDataUpdater.updateFriendWithID(friendModel.idTbm, setAvatarTimestamp: friendModel.avatarTimestamp)
            self.delegate?.didDownloadAvatar(forFriend: friendModel)
            
            return nil
        })
    }
}
