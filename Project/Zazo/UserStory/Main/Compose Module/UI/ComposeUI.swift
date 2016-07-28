//
//  ComposeUI.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

protocol ComposeUIInput {
    func typedText() -> String
    func showLoading(loading: Bool)
}

protocol ComposeUIOutput {
    func didTapCancel()
    func didTapSend()
    func didTapKeyboard()
}