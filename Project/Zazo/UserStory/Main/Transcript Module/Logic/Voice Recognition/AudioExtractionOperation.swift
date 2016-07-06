//
//  AudioExtractionOperation.swift
//  Zazo
//
//  Created by Rinat Gabdullin on 28/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import AVFoundation

public class AudioExtractor {
    
    static let settings: [String: AnyObject] = [
        AVSampleRateKey: 8000,
        AVNumberOfChannelsKey: 1,
        AVFormatIDKey: Int(kAudioFormatLinearPCM),
        AVChannelLayoutKey: NSData(),
        AVLinearPCMBitDepthKey: 16,
        AVLinearPCMIsFloatKey: false,
        AVLinearPCMIsBigEndianKey: false,
        AVLinearPCMIsNonInterleaved: true,
    ]
    
    public func extractRawAudio(fileURL: NSURL) -> NSData? {
        
        print("Audio extraction started: ", NSDate())
        let asset = AVAsset(URL: fileURL)
        
        guard let reader = try? AVAssetReader(asset: asset) else {
            return nil
        }
        
        let output = AVAssetReaderAudioMixOutput(audioTracks: asset.tracksWithMediaType(AVMediaTypeAudio),
                                                 audioSettings: AudioExtractor.settings)
        
        reader.addOutput(output)
        
        guard reader.startReading() else {
            return nil
        }

        let data = NSMutableData()

        while let sampleBuffer = output.copyNextSampleBuffer() {
            
            let buffer = CMSampleBufferGetDataBuffer(sampleBuffer)
            
            var pointer: UnsafeMutablePointer<Int8> = nil
            var length: size_t = 0
            
            guard CMBlockBufferGetDataPointer(buffer!, 0, nil, &length, &pointer) == kCMBlockBufferNoErr else {
                return nil
            }
            
            let sample = NSData(bytesNoCopy: pointer, length: length, deallocator: nil)
            
            data.appendData(sample)
        }
        
        print("Audio extraction completed: ", NSDate())
        
        return data
    }
}