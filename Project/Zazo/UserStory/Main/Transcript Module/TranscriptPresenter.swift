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
        
        view.showPlayer(playbackController.playerView)
        view.showPlaybackControl(playbackController.playbackIndicator)
        
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

public protocol Sortable: Equatable {
    func value() -> Int
}

extension RecognitionResult: Sortable {
    public func value() -> Int {
        return Int(self.date.timeIntervalSince1970)
    }
}

class SortingContainer<T: Sortable> {
    
    var sorted: [T] {
        return _sorted
    }
    
    private var _sorted = [T]()
    
    func add(item item: T) {
        let index = _sorted.indexOf { $0.value() > item.value() } ?? _sorted.count
        _sorted.insert(item, atIndex: index)
    }
}
