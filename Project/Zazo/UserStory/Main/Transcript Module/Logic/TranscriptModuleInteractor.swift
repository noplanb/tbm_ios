//
//  TranscriptModuleInteractor.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

class TranscriptModuleInteractor: TranscriptLogic, RecognitionManagerOutput {
    
    var recognitionManager: RecognitionManager?

    func videosFromFriendWithID(id: String) -> [ZZVideoDomainModel] {
        return []
    }
    
    func recognizeVideo(fileURL: NSURL, completion: String -> Void) {
        completion("asd")
    }
    
    func didRecognize(url: NSURL, result: String) {
        
    }
    
    func didFailRecognition(url: NSURL, error: NSError) {
        
    }

}