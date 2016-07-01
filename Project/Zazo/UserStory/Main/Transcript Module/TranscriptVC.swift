//
//  TranscriptModuleVC.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

class TranscriptVC: UIViewController, TranscriptUIInput {
    
    var output: TranscriptUIOutput?
    
    override func loadView() {
        view = TranscriptView()
    }
    
    func loading(ofType type:TranscriptUILoadingType, isVisible visible:Bool) {
        
    }
    
    func add(transcript text:String, with time:NSDate) {
        
    }
    
    func setVolumeEnabled(enabled:Bool) {
        
    }
}