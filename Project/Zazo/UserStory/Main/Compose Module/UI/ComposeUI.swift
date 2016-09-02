//
//  ComposeUI.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

protocol ComposeUIInput: class {
    func typedText() -> String
    func showLoading(loading: Bool)
    func showFriendName(name: String)
    func askForRetry(text: String?, completion: (Bool)->())
}

protocol ComposeUIOutput: class {
    func didTapCancel()
    func didTapSend()
    func didTapKeyboard()
}