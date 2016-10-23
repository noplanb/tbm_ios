//
//  ComposeModuleInterface.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

@objc public protocol ComposeModuleDelegate: class {
    func didSendMessage(to friend: ZZFriendDomainModel)
}

@objc public protocol ComposeModule {
    
    func present(from view: UIView)
    func isBeingPresented() -> Bool

}
