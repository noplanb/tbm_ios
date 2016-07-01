//
//  TranscriptModulePresenter.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

class TranscriptPresenter: TranscriptModule, TranscriptUIOutput {
    
    let view: TranscriptUIInput
    let logic: TranscriptLogic
    let router: TranscriptRouter
    
    init(view: TranscriptUIInput,
         logic: TranscriptLogic,
         router: TranscriptRouter)
    {
        self.view = view
        self.logic = logic
        self.router = router
    }
    
    // MARK: TranscriptModule interface
    
    func present(for friendWithID: String) {
        router.show()
        
    }
    
    // MARK: TranscriptUIOutput interface
    
    func didTapReplyButton() {
        
    }
    
    func didTapCloseButton() {
        
    }
    
    func didTapMuteButton() {
        
    }

}