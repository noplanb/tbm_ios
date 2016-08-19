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
        
    var friendModel: ZZFriendDomainModel!
    
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
        self.view.showFriendName(friendModel.fullName())
        router.show(from: view, completion: nil)
    }
    
    @objc func isBeingPresented() -> Bool {
        return router.isBeingPresented
    }
    
    // MARK: ComposeLogicOutput
    

    // MARK: ComposeUIOutput interface

    func didTapCancel() {
        router.hide()
    }
    
    func didTapSend() {
        
        view.showLoading(true)
        
        logic.sendMessage(view.typedText()).start { (event) in
            
            self.view.showLoading(false)
            self.router.hide()
            
            switch event {
            case .Failed(let error):
                logWarning("\(error)")
            default:
                break
            }
        }
    }
    
    func didTapKeyboard() {
        
    }
}