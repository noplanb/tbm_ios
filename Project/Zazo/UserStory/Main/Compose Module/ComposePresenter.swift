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
    
    weak var delegate: ComposeModuleDelegate?
    
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
        router.hide(nil)
    }
    
    func didTapSend() {
        
        let text = view.typedText().stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        guard text.characters.count > 0 else {
            return
        }
        
        sendMessage(text)
    }
    
    func sendMessage(text: String) {
        view.showLoading(true)
        
        logic.sendMessage(text).start { (event) in
            
            self.view.showLoading(false)
            
            switch event {
                case .Failed(let error):
                    self.sending(text, didFailedWith: error)
                case .Completed:
                    self.router.hide({
                        self.delegate?.didSendMessage(to: self.friendModel)
                    })
            default:
                break
            }
        }

    }
    
    func sending(message: String, didFailedWith error:ServiceError) {
        logWarning("\(error)")
        
        view.askForRetry(error.toString()) { (shouldRetry) in
            if shouldRetry {
                self.sendMessage(message)
            }
        }
    }
    
    func didTapKeyboard() {
        
    }
}
