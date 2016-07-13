//
//  TranscriptModulePresenter.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

class TranscriptPresenter: TranscriptModule, TranscriptUIOutput, TranscriptLogicOutput {
    
    let view: TranscriptUIInput
    let logic: TranscriptLogic
    let router: TranscriptRouter
    
    var volumeEnabled = false
    
    let playbackController = ZZPlayerController()
    
    var friendModel: ZZFriendDomainModel?
    
    init(view: TranscriptUIInput,
         logic: TranscriptLogic,
         router: TranscriptRouter)
    {
        self.view = view
        self.logic = logic
        self.router = router
    }
    
    // MARK: TranscriptModule interface
    
    @objc func present(for friendID: String, from sourceView: UIView) {
        
        view.setVolumeEnabled(volumeEnabled)
        playbackController.muted = !volumeEnabled
        
        let friendData = logic.fetchFriendData(forID: friendID)
        
        if let thumb = friendData.thumbnail {
            view.setThumbnail(thumb)
        }
        
        view.setFriendName(friendData.friendModel.fullName())
        
        logic.startRecognizingVideos(for: friendID)
        
        view.loading(ofType: .Transcript, isVisible: true)
        
        view.showPlayer(playbackController.playerView)
        view.showPlaybackControl(playbackController.playbackIndicator)
        
        friendModel = friendData.friendModel
        
        router.show(from: sourceView)
    }
    
    // MARK: TranscriptLogicOutput
    
    func didRecognizeVideoAtIndex(with result: RecognitionResult) {
        
        view.add(transcript: result.text, with: result.date)
        
        if result.index == 0 {
            playbackController.playVideoForFriend(friendModel)
        }
        
    }
    
    func didCompleteRecognition(error: NSError?) {
        view.loading(ofType: .Transcript, isVisible: false)
    }
    
    func didFailWithVideoAtIndex(index: UInt, with error: NSError?) {
        view.add(transcript: "(Recognition failed)", with: NSDate())
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

}