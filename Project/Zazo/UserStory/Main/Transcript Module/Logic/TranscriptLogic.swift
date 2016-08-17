//
//  TranscriptLogic.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

public struct RecognitionResult {
    var videoID: String?
    var text: String
    let date: NSDate
}

public func ==(lhs: RecognitionResult, rhs: RecognitionResult) -> Bool {
    return lhs.date == rhs.date && lhs.text == rhs.text
}

protocol TranscriptLogicOutput: class {
    func didRecognize(with result: RecognitionResult)
    func didCompleteRecognition()
}

protocol TranscriptLogic: class {
    func startRecognizingVideos(for friendID: String)
    func fetchFriendData(forID friendID: String) -> (thumbnail: UIImage?, friendModel: ZZFriendDomainModel)
}

