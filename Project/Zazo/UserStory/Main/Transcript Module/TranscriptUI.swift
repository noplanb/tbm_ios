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

protocol TranscriptUIInput {
    func loading(ofType type:TranscriptUILoadingType, isVisible visible:Bool)
    func add(transcript text:String, with time:NSDate)
    func setVolumeEnabled(enabled:Bool)
    func setThumbnail(image: UIImage)
    func setFriendName(name: String)
    func showPlayer(view: UIView)
    func showPlaybackControl(view: UIView)
}

protocol TranscriptUIOutput
{
    func didTapReplyButton()
    func didTapCloseButton()
    func didTapMuteButton()
    func didStartInteractiveDismissal()
    func didCancelInteractiveDismissal()
}