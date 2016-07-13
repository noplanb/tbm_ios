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
    var recognizingVideos = [ZZVideoDomainModel]()

    func startRecognizingVideos(for friendID: String) {
        
        let friendModel = ZZFriendDataProvider.friendWithItemID(friendID)

        recognitionManager?.operationQueue.cancelAllOperations()
        
        let alreadyRecognized = friendModel.videos.filter { $0.transcription != nil }
        
        for videoModel in alreadyRecognized {
            
            let index = friendModel.videos.indexOf(videoModel)
            
            let result = RecognitionResult(text: videoModel.transcription,
                                           model: videoModel,
                                           index: UInt(index!),
                                           date: _date(videoID: videoModel.videoID))
            
            didRecognize(result)
        }
        
        recognizingVideos = friendModel.videos.filter { (videoModel) -> Bool in

            if videoModel.transcription != nil {
                return false
            }
            
            return videoModel.incomingStatusValue ==
                ZZVideoIncomingStatus.Downloaded || videoModel.incomingStatusValue == ZZVideoIncomingStatus.Viewed
        }
            
        recognizingURLs = recognizingVideos.map { $0.videoURL }
        
        let completion = {
            GCDBlock.async(.Main, closure: {
                self.output?.didCompleteRecognition(nil)
            })
        }
        
        if recognizingVideos.count == 0 {
            completion()
            return
        }
        
        let completionOperation = NSBlockOperation {
            completion()
        }

        for url in recognizingURLs {
            if let operation = self.recognitionManager?.recognizeFile(url) {
                completionOperation.addDependency(operation)
            }
        }
        
        self.recognitionManager?.operationQueue.addOperation(completionOperation)
        
    }
    
    func cancelRecognizingVideos() {
        recognitionManager?.operationQueue.cancelAllOperations()
    }
    
    func fetchFriendData(forID friendID: String) -> (thumbnail: UIImage?, friendModel: ZZFriendDomainModel) {
        
        let friendModel = ZZFriendDataProvider.friendWithItemID(friendID)
        
        let thumb = ZZThumbnailGenerator.thumbImageForUser(friendModel)
        
        return (thumb, friendModel)
        
    }
    
    func didRecognize(url: NSURL, result text: String) {
        
        if let index = recognizingURLs.indexOf(url) {
            
            let videoModel = recognizingVideos[index]
            
            let result = RecognitionResult(text: text,
                                           model: videoModel,
                                           index: UInt(index),
                                           date: _date(videoID: videoModel.videoID))
            
            ZZVideoDataUpdater.updateVideoWithID(videoModel.videoID, setTranscription: text)
            
            videoViewed(result.model)

            didRecognize(result)
        }
        
    }
    
    func didFailRecognition(url: NSURL, error: NSError) {
        
        if let index = recognizingURLs.indexOf(url) {
            
            GCDBlock.async(.Main) {
                self.output?.didFailWithVideoAtIndex(UInt(index), with: error)
            }
            
        }
    }

    // MARK: Other
    
    
    func didRecognize(result: RecognitionResult) {
        GCDBlock.async(.Main) {
            self.output?.didRecognizeVideoAtIndex(with: result)
        }
    }
    
    func _date(videoID id: String) -> NSDate {
        
        let timestamp: NSTimeInterval = NSTimeInterval(id)! / 1000;
        return NSDate(timeIntervalSince1970: timestamp);
        
    }
    
    func videoViewed(videoModel: ZZVideoDomainModel) {
        
        if let friendModel = ZZFriendDataProvider.friendWithItemID(videoModel.relatedUserID) {
            
            ZZVideoStatusHandler.sharedInstance().setAndNotityViewedIncomingVideoWithFriendID(friendModel.idTbm,
                                                                                              videoID: videoModel.videoID)
            
            ZZRemoteStorageTransportService.updateRemoteStatusForVideoWithItemID(friendModel.idTbm,
                                                                                 toStatus: .Viewed,
                                                                                 friendMkey: friendModel.mKey,
                                                                                 friendCKey: friendModel.cKey)
        }
        

    }
}