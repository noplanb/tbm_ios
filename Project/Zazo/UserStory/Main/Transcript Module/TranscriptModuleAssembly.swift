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
    
    @objc public var module: TranscriptModule {
        return presenter
    }
    
    init(with parentVC: UIViewController) {
        
        interactor = TranscriptInteractor()
        
        let manager = RecognitionManager(output: interactor)
        manager.registerType(NuanceRecognitionOperation)
        interactor.recognitionManager = manager
        
        viewController = TranscriptVC(nibName: nil, bundle: nil)
        
        let router = TranscriptRouter(forPresenting: viewController, in: parentVC)
        
        presenter = TranscriptPresenter(view: viewController,
                                        logic: interactor,
                                        router: router)
        
        viewController.output = presenter
    }
}