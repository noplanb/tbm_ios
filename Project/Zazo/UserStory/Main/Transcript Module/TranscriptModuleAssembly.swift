//
//  TranscriptModuleAssembly.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

@objc public class TranscriptModuleAssembly: NSObject {
    
    private let viewController: TranscriptVC
    private let presenter: TranscriptPresenter
    private let interactor: TranscriptInteractor
    private let router: TranscriptRouter
    
    @objc public var module: TranscriptModule {
        return presenter
    }
    
    init(with parentVC: UIViewController) {
        
        interactor = TranscriptInteractor()
        
        let client = NetworkClient()
        client.baseURL = NSURL(string: APIBaseURL())
        
        interactor.messagesService = ConcreteMessagesService(client: client)
        viewController = TranscriptVC(nibName: nil, bundle: nil)
        router = TranscriptRouter(forPresenting: viewController, in: parentVC)
        
        presenter = TranscriptPresenter()
        presenter.view = viewController
        presenter.logic = interactor
        presenter.router = router
        
        router.delegate = presenter

        viewController.output = presenter
        interactor.output = presenter
    }
}
