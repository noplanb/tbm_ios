//
//  TranscriptLogic.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

protocol TranscriptLogic {
    
    func videosFromFriendWithID(id: String) -> [ZZVideoDomainModel]
    
    func recognizeVideo(fileURL: NSURL, completion: String -> Void)
    
    func getThumbnailForFriendID(friendID: String) -> UIImage?
    
}