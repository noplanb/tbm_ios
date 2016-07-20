//
//  ComposeModulePresenter.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

class ComposePresenter: ComposeModule, ComposeUIOutput, ComposeLogicOutput {
    
    let view: ComposeUIInput
    let logic: ComposeLogic
    let router: ComposeRouter
    
    var volumeEnabled = false
    
    let playbackController = ZZPlayerController()
    
    var friendModel: ZZFriendDomainModel?
    
    init(view: ComposeUIInput,
         logic: ComposeLogic,
         router: ComposeRouter)
    {
        self.view = view
        self.logic = logic
        self.router = router
    }
    
    // MARK: ComposeModule interface
    
    @objc func present(from view: UIView) {
        router.show(from: view, completion: nil)
    }
    
    // MARK: ComposeLogicOutput
    

    // MARK: ComposeUIOutput interface

    func didTapCancel() {
        router.hide()
    }
}