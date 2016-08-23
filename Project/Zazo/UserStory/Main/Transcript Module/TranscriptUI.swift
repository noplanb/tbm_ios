//
//  TranscriptUI.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

enum TranscriptUILoadingType {
    case Transcript
}

protocol TranscriptUIInput: class {

    func insertItem(text:String,
                    index: UInt,
                    time:NSDate)
    
    func loading(ofType type:TranscriptUILoadingType, isVisible visible:Bool)
    func setVolumeEnabled(enabled:Bool)
    func setThumbnail(image: UIImage)
    func setFriendName(name: String)
    func showPlayer(view: UIView)
    func showPlaybackControl(view: UIView)
}

protocol TranscriptUIOutput: class
{
    func didTapAtItem(at index: Int)
    func didTapReplyButton()
    func didTapCloseButton()
    func didTapMuteButton()
    func didTapBackground()
    func didStartInteractiveDismissal()
    func didCancelInteractiveDismissal()
}