//
//  AvatarStorageService.swift
//  Zazo
//
//  Created by Rinat on 15/09/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

class AvatarStorageService: NSObject {
    
    static let sharedService = AvatarStorageService(withName: "avatar.png")
    
    let avatarFileURL: NSURL
    let fileManager = NSFileManager.defaultManager()
    
    init(withName filename: String) {
        let avatarRootDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first
        let avatarRootDirectory = NSURL(fileURLWithPath: avatarRootDirectoryPath!)
        avatarFileURL = NSURL(string: filename, relativeToURL: avatarRootDirectory)!
    }
    
    /**
     Replaces (or adds) avatar
     
     - parameter image: avatar
     */
    func update(with image: UIImage) {
        
        guard let data = UIImagePNGRepresentation(image) else {
            return
        }
        
        remove()
        
        fileManager.createFileAtPath(avatarFileURL.absoluteString, contents: data, attributes: nil)
    }
    
    /**
     Removes avatar from storage
     */
    func remove() {
        guard isAvatarExists else {
            return;
        }
        
        do {
           try fileManager.removeItemAtURL(avatarFileURL)
        }
        catch {
            logError("avatar deletion error: \(error)")
        }
    }
    
    /**
     Returns avatar image if exists
     
     - returns: avatar
     */
    func get() -> UIImage? {
        guard isAvatarExists else {
            return nil;
        }
        
        guard let path = avatarFileURL.absoluteString else {
            return nil
        }
        
        guard let image = UIImage(contentsOfFile: path) else {
            return nil
        }
        
        return image
    }
    
    // MARK: Private
    
    private var isAvatarExists: Bool {
        get {
            guard let path = avatarFileURL.absoluteString else {
                return false
            }
            
            return fileManager.fileExistsAtPath(path)
        }
    }
}
