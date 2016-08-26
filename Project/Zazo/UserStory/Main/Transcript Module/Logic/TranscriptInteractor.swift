//
//  TranscriptModuleInteractor.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import GCDKit
import Result
import ReactiveCocoa

class TranscriptInteractor: TranscriptLogic {
    
    weak var output: TranscriptLogicOutput?
    var messagesService: MessagesService!
    var recognizingVideos = [ZZVideoDomainModel]()
    var recognizingDisposable: Disposable?
    
    func startRecognizingVideos(for friendID: String) -> Bool {
        
        self.stopRecognition()
        
        let friendModel = ZZFriendDataProvider.friendWithItemID(friendID)
        let videos = friendModel.videos.filter{ $0.incomingStatusValue == .Downloaded || $0.incomingStatusValue == .Viewed }
        let messages = friendModel.messages
        let alreadyRecognized = videos.filter{ $0.transcription != nil }
        
        for videoModel in alreadyRecognized {
            
            let result = RecognitionResult(videoID: videoModel.videoID,
                                           text: videoModel.transcription,
                                           date: _date(videoID: videoModel.videoID))
            didRecognize(result)
        }
        
        for messageModel in messages {
            
            let result = RecognitionResult(videoID: nil,
                                           text: messageModel.body,
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

        
        if recognizingVideos.count == 0 {
            self.output?.didCompleteRecognition()
            return false
        }
        
        let recognizingSignal = SignalProducer<SignalProducer<RecognitionResult, ServiceError>, NoError>{
            observer, disposal in
            
            for videoModel in self.recognizingVideos {
                
                var result = RecognitionResult(videoID: videoModel.videoID,
                                                  text: nil,
                                                  date: self._date(videoID: videoModel.videoID))
                
                let signal = self.messagesService.getTranscript(by: videoModel.videoID)
                    .map({ (response) -> RecognitionResult in
                        
                        result.text = response.data.transcription
                        return result
                        
                    })
                    .flatMapError{
                        _ in SignalProducer<RecognitionResult, ServiceError>(value: result)
                    }
                
                observer.sendNext(signal)
            }
            observer.sendCompleted()
        }
        
        recognizingDisposable =
        recognizingSignal.flatten(.Concat).start { (event) in
            switch event {
            case .Next(let result):
                self.saveTranscript(from: result)
                self.didRecognize(result)
            case .Completed:
                self.didCompleteRecognition()
            case .Failed(let error):
                logError("\(error)")
                self.didCompleteRecognition()
            default:
                break
            }
        }
        
        return true
    }
    
    
    func fetchFriendData(forID friendID: String) -> (thumbnail: UIImage?, friendModel: ZZFriendDomainModel) {
        
        let friendModel = ZZFriendDataProvider.friendWithItemID(friendID)
        let thumb = ZZThumbnailGenerator.thumbImageForUser(friendModel)
        return (thumb, friendModel)
        
    }
    


    // MARK: Other

    func stopRecognition() {
        if let recognizingDisposable = recognizingDisposable {
            recognizingDisposable.dispose()
        }
    }
    
    func saveTranscript(from result: RecognitionResult) {
        
        guard let videoID = result.videoID else {
            return
        }
        
        let videoModel = ZZVideoDataProvider.itemWithID(videoID)
        videoViewed(videoModel)
        
        guard result.text?.characters.count > 0 else {
            return;
        }
        
        ZZVideoDataUpdater.updateVideoWithID(result.videoID, setTranscription: result.text)

    }
    
    func didRecognize(result: RecognitionResult) {
        GCDBlock.async(.Main) {
            self.output?.didRecognize(with: result)
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
    
    func didCompleteRecognition() {
        GCDBlock.async(.Main) {
            self.output?.didCompleteRecognition()
        }
    }
}
