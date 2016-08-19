//
//  ComposeModuleAssembly.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

@objc public class ComposeAssembly: NSObject {
    
    private let viewController: ComposeVC
    private let presenter: ComposePresenter
    private let interactor: ComposeInteractor
    
    @objc public var module: ComposeModule {
        return presenter
    }
    
    init?(presentFromVC parentVC: UIViewController, toFriendWithKey mKey: String) {
        
        guard let friendModel = ZZFriendDataProvider.friendWithMKeyValue(mKey) else {
            logError("invalid mkey")
            return nil
        }
        
        interactor = ComposeInteractor()
        
        let service = ConcreteMessagesService(client: NetworkClient())
        
        interactor.friendMkey = mKey
        interactor.service = service
        
        viewController = ComposeVC(nibName: nil, bundle: nil)
        
        let router = ComposeRouter(forPresenting: viewController, in: parentVC)
        
        presenter = ComposePresenter(view: viewController,
                                        logic: interactor,
                                        router: router)
        
        presenter.friendModel = friendModel
        viewController.output = presenter
        interactor.output = presenter
    }
}