//
//  AvatarUpdateService.swift
//  Zazo
//
//  Created by Rinat on 15/09/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

@objc protocol AvatarUpdateServiceDelegate: class {
    func avatarNeedsToBeUpdated(completion: ANCodeBlock)
    func avatarFetchFailed(errorText: String)
}

class AvatarUpdateService: NSObject {
    
    weak var delegate: AvatarUpdateServiceDelegate?
    
    /// Dependencies:
    var legacyAvatarService: LegacyAvatarService! = nil {
        didSet {
            if let service = legacyAvatarService as? AvatarService {
                avatarService = service
            }
        }
    }
    var avatarService: AvatarService! = nil
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    let persistenceKey: String
    
    init(with persistenceKey: String) {
        self.persistenceKey = persistenceKey
        lastTimestamp = 0
        super.init()
        lastTimestamp = NSTimeInterval(userDefaults.floatForKey(timestampPersistenceKey))
    }
    
    func checkUpdate() {
        avatarService.get().start { (event) in
            switch event {
                case .Next(let result): self.handleResult(result)
                case .Failed(let error): self.handleError(error)
                default: break
            }
        }
    }
    
    private func handleResult(result: GetAvatarResponse) {
        
        let currentTimestamp = result.data.timestamp ?? 0
        guard currentTimestamp > lastTimestamp else {
            return
        }
        
        self.delegate!.avatarNeedsToBeUpdated {
            self.lastTimestamp = currentTimestamp
        }

    }
    
    private func handleError(error: ServiceError) {
        self.delegate?.avatarFetchFailed(error.toString())
    }
    
//    private func fetchAvatar(withTimestamp value: NSTimeInterval) {
//        
//    }
//    
//    private func didCompleteFetchingAvatar(timestamp: NSTimeInterval, data: NSData) {
//        
//        guard let image = UIImage(data: data) else {
//            return
//        }
//        
//    }
    
    // MARK: Timestamp persistence
    
    var timestampPersistenceKey: String {
        get {
            return "\(persistenceKey)-timestamp"
        }
    }
    
    private var lastTimestamp: NSTimeInterval {
        didSet {
            if oldValue != lastTimestamp {
                persistTimestamp(lastTimestamp)
            }
        }
    }
    
    private func persistTimestamp(value: NSTimeInterval) {
        userDefaults.setDouble(value, forKey: timestampPersistenceKey)
    }
}