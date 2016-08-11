//
//  TranscriptLogic.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

public struct RecognitionResult {
    let text: String
    let date: NSDate
}

public func ==(lhs: RecognitionResult, rhs: RecognitionResult) -> Bool {
    return lhs.date == rhs.date && lhs.text == rhs.text
}

protocol TranscriptLogicOutput {
    func didRecognizeVideoAtIndex(with result: RecognitionResult)
    func didFailWithVideoAtIndex(index: UInt, with error: NSError?)
    func didCompleteRecognition(error: NSError?)
}

protocol TranscriptLogic {
    func startRecognizingVideos(for friendID: String)
    func fetchFriendData(forID friendID: String) -> (thumbnail: UIImage?, friendModel: ZZFriendDomainModel)
}

