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
    
    var volumeEnabled = true
    
    init(view: TranscriptUIInput,
         logic: TranscriptLogic,
         router: TranscriptRouter)
    {
        self.view = view
        self.logic = logic
        self.router = router
    }
    
    // MARK: TranscriptModule interface
    
    @objc func present(for friendID: String) {
        
        view.setVolumeEnabled(volumeEnabled)
        
        let friendData = logic.fetchFriendData(forID: friendID)
        
        if let thumb = friendData.thumbnail {
            view.setThumbnail(thumb)
        }
        
        view.setFriendName(friendData.name)
        
        logic.startRecognizingVideos(for: friendID)
        
        view.loading(ofType: .Transcript, isVisible: true)
        
        router.show()
    }
    
    // MARK: TranscriptLogicOutput
    
    func didRecognizeVideoAtIndex(index: UInt, with result: String) {
        view.add(transcript: result, with: NSDate())
    }
    
    func didCompleteRecognition(error: NSError?) {
        view.loading(ofType: .Transcript, isVisible: false)
    }
    
    // MARK: TranscriptUIOutput interface
    
    func didTapReplyButton() {
        
    }
    
    func didTapCloseButton() {
        router.hide()
    }
    
    func didTapMuteButton() {
        
        volumeEnabled = !volumeEnabled
        view.setVolumeEnabled(volumeEnabled)
    }

}