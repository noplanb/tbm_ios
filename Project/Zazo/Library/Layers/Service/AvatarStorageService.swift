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
        
        if !data.writeToURL(avatarFileURL, atomically: true) {
            logError("avatar saving failed: \(errno) \(String.fromCString(strerror(errno)))")
        }
    }
    
    /**
     Removes avatar from storage
     */
    func remove() {
        do {
           try fileManager.removeItemAtURL(avatarFileURL)
        }
        catch {
            
        }
    }
    
    /**
     Returns avatar image if exists
     
     - returns: avatar
     */
    func get() -> UIImage? {
    
        guard let imageData = NSData(contentsOfURL: avatarFileURL) else {
            return nil
        }
        
        let screenScale = UIScreen.mainScreen().scale
        
        guard let image = UIImage(data: imageData, scale: screenScale) else {
            return nil
        }
        
        return image
    }
}
