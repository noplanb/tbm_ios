//
//  TranscriptModulePresenter.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import GCDKit

class TranscriptPresenter: TranscriptModule, TranscriptUIOutput, TranscriptLogicOutput, TranscriptRouterDelegate {
    
    weak var view: TranscriptUIInput!
    weak var logic: TranscriptLogic!
    weak var router: TranscriptRouter!
    
    var volumeEnabled = false
    let playbackController = ZZPlayerController()
    var friendModel: ZZFriendDomainModel?
    
    // MARK: TranscriptModule interface
    
    @objc func present(for friendID: String, from sourceView: UIView) {
        
        view.setVolumeEnabled(volumeEnabled)
        playbackController.muted = !volumeEnabled
        
        let friendData = logic.fetchFriendData(forID: friendID)
        
        if let thumb = friendData.thumbnail {
            view.setThumbnail(thumb)
        }
        
        view.setFriendName(friendData.friendModel.fullName())
        
        if friendData.friendModel.videos.count > 0 {
            view.showPlayer(playbackController.playerView)
            view.showPlaybackControl(playbackController.playbackIndicator)            
        }
        
        friendModel = friendData.friendModel
        
        router.show(from: sourceView) { (finished) in
            self.startRecognition()
        }
        
        playbackController.hideTextMessages = true
    }
    
    // MARK: TranscriptLogicOutput
    
    func didRecognize(with result: RecognitionResult) {
        
        if result.text == nil {
            hasFailedRecognitions = true
        }
        
        insertToView(recognizingResult: result)        
    }
    
    func didCompleteRecognition() {
        view.loading(ofType: .Transcript, isVisible: false)
        
        if hasFailedRecognitions {
            view.askRetry({ (shouldRetry) in
                if shouldRetry {
                    self.startRecognition()
                }
                else {
                    self.startPlaying()
                }
            })
        }
        else {
            self.startPlaying()
        }
    }
    
    // MARK: TranscriptUIOutput interface
    
    func didTapReplyButton() {
        
    }
    
    func didTapCloseButton() {
        playbackController.stop()
        router.hide()
    }
    
    func didTapMuteButton() {
        volumeEnabled = !volumeEnabled
        view.setVolumeEnabled(volumeEnabled)
        playbackController.muted = !volumeEnabled
    }

    func didStartInteractiveDismissal() {
        playbackController.paused = true
    }
    
    func didCancelInteractiveDismissal() {
        GCDBlock.after(.Main, delay: 0.5) {
            let vc = self.router.moduleVC
            guard
                vc.isBeingDismissed() == false &&
                vc.presentingViewController != nil
            else {
                return
            }
            self.playbackController.paused = false
        }
    }
    
    func didTapBackground() {
        router.hide()
    }
    
    func didTapAtItem(at index: Int) {
        let item = recognizedItems.sorted[index]
        
        guard let videoID = item.videoID else {
            return
        }
        
        guard var timestamp = Int(videoID) else {
            return
        }
        
        timestamp = timestamp / 1000
        
        self.playbackController.gotoTimestamp(NSTimeInterval(timestamp))
    }
    
    // MARK: TranscriptRouterDelegate
    
    func didHide() {
        self.playbackController.stop()
        self.logic.stopRecognition()
    }
    
    // MARK: Support
    
    let recognizedItems = SortingContainer<RecognitionResult>()
    var hasFailedRecognitions = false

    func startRecognition() {
        view.clearItems()
        recognizedItems.clear()
        hasFailedRecognitions = false
        if (self.logic.startRecognizingVideos(for: self.friendModel!.idTbm))
        {
            self.view.loading(ofType: .Transcript, isVisible: true)
        }
    }
    
    func insertToView(recognizingResult result: RecognitionResult) {
        
        recognizedItems.add(item: result)
        let index = recognizedItems.sorted.indexOf { result == $0 }
        
        view.insertItem(result.text ?? "",
                        index: UInt(index!),
                        time: result.date)
    }
    
    func startPlaying() {
        playbackController.playVideoForFriend(friendModel)
        playbackController.queue.appendNewItems = false
    }
}

