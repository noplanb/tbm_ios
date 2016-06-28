//
//  AudioExtractionOperation.swift
//  Zazo
//
//  Created by Server on 28/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import AVFoundation

public class AudioExtractionOperation: ConcurrentOperation {
    
    static let settings: [String: AnyObject] = [
        AVSampleRateKey: 8000,
        AVNumberOfChannelsKey: 1,
        AVLinearPCMBitDepthKey: 8,
        AVFormatIDKey: Int(kAudioFormatLinearPCM),
        AVLinearPCMIsFloatKey: false,
        AVLinearPCMIsBigEndianKey: false,
        AVLinearPCMIsNonInterleaved: false,
        AVChannelLayoutKey: NSData()
    ]
    
    let fileURL: NSURL
    
    var error: NSError?
    private (set) public var resultURL: NSURL?
    
    init(withFile fileURL: NSURL) {
        self.fileURL = fileURL
    }
    
    override public func start() {
        
        state = .Executing
        
        let asset = AVAsset(URL: fileURL)
        
        guard let reader = try? AVAssetReader(asset: asset) else {
            failOperation()
            return
        }
        
        let output = AVAssetReaderAudioMixOutput(audioTracks: asset.tracksWithMediaType(AVMediaTypeAudio),
                                                 audioSettings: AudioExtractionOperation.settings)
        
        reader.addOutput(output)
        
        let resultURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(filename())
        
        let manager = NSFileManager.defaultManager()
        
        if manager.fileExistsAtPath(resultURL.path!) {
            try! manager.removeItemAtURL(resultURL)
        }
        
        guard let writer = try? AVAssetWriter(URL: resultURL, fileType: AVFileTypeCoreAudioFormat) else {
            failOperation()
            return
        }
        
        let input = AVAssetWriterInput(mediaType: AVMediaTypeAudio,
                                       outputSettings: AudioExtractionOperation.settings)
        
        writer.addInput(input)
        
        input.expectsMediaDataInRealTime = false
        
        guard writer.startWriting() else {
            failOperation()
            return
        }
        
        guard reader.startReading() else {
            failOperation()
            return
        }
        
        writer.startSessionAtSourceTime(kCMTimeZero)
        
        let queue = dispatch_queue_create("queue", nil)
        
        input.requestMediaDataWhenReadyOnQueue(queue) {
            
            while input.readyForMoreMediaData {
                
                if let sampleBuffer = output.copyNextSampleBuffer() {
                    
                    if !input.appendSampleBuffer(sampleBuffer) {
                        self.failOperation()
                        break
                    }
                    
                } else {
                    
                    input.markAsFinished()
                    break
                }
            }
            
            writer.finishWritingWithCompletionHandler {
                
                if writer.status == AVAssetWriterStatus.Failed {
                    self.error = writer.error
                }
                else {
                    self.resultURL = resultURL
                }
                self.state = .Finished
            }
        }
        
        
    }
    
    func filename() -> String {
        var name = fileURL.URLByDeletingPathExtension?.lastPathComponent
        name?.appendContentsOf(".wav")
        
        return name!
        
    }
    
    func failOperation() {
        state = .Finished
        
    }
}