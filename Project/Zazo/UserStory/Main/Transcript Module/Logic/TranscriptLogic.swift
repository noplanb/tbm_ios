//
//  TranscriptLogic.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

protocol TranscriptLogicOutput {
    
    func didRecognizeVideoAtIndex(index: UInt, with result: String)
    
}

protocol TranscriptLogic {
    
    func startRecognizingVideos(for friendID: String)
    
    func getThumbnailForFriendID(friendID: String) -> UIImage?
    
}