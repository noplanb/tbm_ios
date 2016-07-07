//
//  TranscriptLogic.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

struct FriendData {
    let thumbnail: UIImage?
    let name: String
}

protocol TranscriptLogicOutput {
    
    func didRecognizeVideoAtIndex(index: UInt, with result: String)
    func didCompleteRecognition(error: NSError?)
    
}

protocol TranscriptLogic {
    
    func startRecognizingVideos(for friendID: String)
    
    func fetchFriendData(forID friendID: String) -> FriendData
    
}