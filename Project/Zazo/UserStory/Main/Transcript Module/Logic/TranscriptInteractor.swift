//
//  TranscriptModuleInteractor.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

class TranscriptInteractor: TranscriptLogic, RecognitionManagerOutput {
    
    var recognitionManager: RecognitionManager?

    func videosFromFriendWithID(id: String) -> [ZZVideoDomainModel] {
        return []
    }
    
    func recognizeVideo(fileURL: NSURL, completion: String -> Void) {
        completion("asd")
    }
    
    @objc func didRecognize(url: NSURL, result: String) {
        
    }
    
    @objc func didFailRecognition(url: NSURL, error: NSError) {
        
    }

}