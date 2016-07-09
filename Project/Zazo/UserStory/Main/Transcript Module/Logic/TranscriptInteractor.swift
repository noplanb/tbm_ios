//
//  TranscriptModuleInteractor.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import GCDKit

class TranscriptInteractor: TranscriptLogic, RecognitionManagerOutput {
    
    var output: TranscriptLogicOutput?
    
    var recognitionManager: RecognitionManager?
    
    var recognizingURLs = [NSURL]()


    func startRecognizingVideos(for friendID: String) {
        
        let friendModel = ZZFriendDataProvider.friendWithItemID(friendID)

        recognitionManager?.operationQueue.cancelAllOperations()
        
        recognizingURLs = friendModel.videos.filter { (videoModel) -> Bool in
            
            return videoModel.incomingStatusValue == ZZVideoIncomingStatus.Downloaded || videoModel.incomingStatusValue == ZZVideoIncomingStatus.Viewed
            
        } .map { (videoModel) -> NSURL in
            return videoModel.videoURL
        }
        
        let completion = NSBlockOperation {
            GCDBlock.async(.Main, closure: {
                self.output?.didCompleteRecognition(nil)
            })
        }

        for url in recognizingURLs {
            if let operation = self.recognitionManager?.recognizeFile(url) {
                completion.addDependency(operation)
            }
        }
        
        
        self.recognitionManager?.operationQueue.addOperation(completion)
        
    }
    
    func cancelRecognizingVideos() {
        recognitionManager?.operationQueue.cancelAllOperations()
    }
    
    func fetchFriendData(forID friendID: String) -> (thumbnail: UIImage?, friendModel: ZZFriendDomainModel) {
        
        let friendModel = ZZFriendDataProvider.friendWithItemID(friendID)
        
        let thumb = ZZThumbnailGenerator.thumbImageForUser(friendModel)
        
        return (thumb, friendModel)
        
    }
    
    func didRecognize(url: NSURL, result: String) {
        
        if let index = recognizingURLs.indexOf(url) {
            
            GCDBlock.async(.Main) {
                self.output?.didRecognizeVideoAtIndex(UInt(index), with: result)
            }
            
        }
        
    }
    
    func didFailRecognition(url: NSURL, error: NSError) {
        
        recognitionManager?.operationQueue.cancelAllOperations()
        
        self.output?.didCompleteRecognition(error)
    }

}