//
//  TranscriptModuleInteractor.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import GCDKit

class TranscriptInteractor: TranscriptLogic {
    
    var output: TranscriptLogicOutput?
    var messagesService: MessagesService!
    var recognizingVideos = [ZZVideoDomainModel]()

    func startRecognizingVideos(for friendID: String) {
        
        let friendModel = ZZFriendDataProvider.friendWithItemID(friendID)
        let videos = friendModel.videos.filter{ $0.incomingStatusValue == .Downloaded || $0.incomingStatusValue == .Viewed }
        let messages = friendModel.messages
        let alreadyRecognized = videos.filter{ $0.transcription != nil }
        
        for videoModel in alreadyRecognized {
            
            let result = RecognitionResult(text: videoModel.transcription,
                                           date: _date(videoID: videoModel.videoID))
            didRecognize(result)
        }
        
        for messageModel in messages {
            
            let result = RecognitionResult(text: messageModel.body,
                                           date: _date(videoID: messageModel.messageID))
            didRecognize(result)
            MessageHandler.sharedInstance.mark(asRead: messageModel)
        }
        
        recognizingVideos = videos.filter { (videoModel) -> Bool in

            if videoModel.transcription != nil {
                return false
            }
            
            return videoModel.incomingStatusValue ==
                ZZVideoIncomingStatus.Downloaded || videoModel.incomingStatusValue == ZZVideoIncomingStatus.Viewed
        }
        
//        let completion = {
//            GCDBlock.async(.Main, closure: {
//                self.output?.didCompleteRecognition(nil)
//            })
//        }
//        
//        if recognizingVideos.count == 0 {
//            completion()
//            return
//        }
        
        for videoModel in recognizingVideos {
            fetchTranscription(forVideoID: videoModel.videoID)
        }
        
    }
    
    func fetchTranscription(forVideoID ID:String) {
        messagesService.getTranscript(by: ID)
    }
    
    func cancelRecognizingVideos() {

    }
    
    func fetchFriendData(forID friendID: String) -> (thumbnail: UIImage?, friendModel: ZZFriendDomainModel) {
        
        let friendModel = ZZFriendDataProvider.friendWithItemID(friendID)
        let thumb = ZZThumbnailGenerator.thumbImageForUser(friendModel)
        return (thumb, friendModel)
        
    }
    
    func didRecognize(videoID: String, result text: String) {
        
//        if let index = recognizingURLs.indexOf(url) {
//            
//            let videoModel = recognizingVideos[index]
//            
//            let result = RecognitionResult(text: text,
//                                           date: _date(videoID: videoModel.videoID))
//            
//            ZZVideoDataUpdater.updateVideoWithID(videoModel.videoID, setTranscription: text)
//            
//            videoViewed(videoModel)
//            didRecognize(result)
//        }
        
    }
    
    func didFailRecognition(url: NSURL, error: NSError) {
        
//        if let index = recognizingURLs.indexOf(url) {
//            
//            GCDBlock.async(.Main) {
//                self.output?.didFailWithVideoAtIndex(UInt(index), with: error)
//            }
//            
//        }
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