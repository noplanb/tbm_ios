//
//  TranscriptModulePresenter.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

class TranscriptPresenter: TranscriptModule, TranscriptUIOutput, TranscriptLogicOutput {
    
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
            self.view.loading(ofType: .Transcript, isVisible: true)
            self.logic.startRecognizingVideos(for: friendID)
        }
        
        playbackController.hideTextMessages = true
    }
    
    // MARK: TranscriptLogicOutput
    
    func didRecognize(with result: RecognitionResult) {
        insertToView(recognizingResult: result)        
    }
    
    func didCompleteRecognition() {
        
        view.loading(ofType: .Transcript, isVisible: false)
        playbackController.playVideoForFriend(friendModel)
    }
    
    func didFailWithVideoAtIndex(index: UInt, with error: NSError?) {
//        view.insertItem("(Recognition failed)", index: index, time: NSDate())
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
        playbackController.paused = false
    }
    
    func didTapBackground() {
        router.hide()
    }
    
    func didTapAtItem(at index: Int) {
        let item = recognizedItems.sorted[index]
        
        guard let videoID = item.videoID else {
            return
        }
        
        let timestamp = Int(videoID)!/1000
        
        self.playbackController.gotoTimestamp(NSTimeInterval(timestamp))
    }
    
    // MARK: Support
    
    let recognizedItems = SortingContainer<RecognitionResult>()
    
    func insertToView(recognizingResult result: RecognitionResult) {
        
        recognizedItems.add(item: result)
        let index = recognizedItems.sorted.indexOf { result == $0 }
        
        view.insertItem(result.text,
                        index: UInt(index!),
                        time: result.date)
    }
}

