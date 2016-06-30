//
//  TranscriptModuleAssembly.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

public class TranscriptModuleAssembly {
    
    private let viewController: TranscriptModuleVC
    private let presenter: TranscriptModulePresenter
    private let interactor: TranscriptModuleInteractor
    
    var module: TranscriptModule {
        return presenter
    }
    
    init(with parentVC: UIViewController) {
        
        interactor = TranscriptModuleInteractor()
        
        let manager = RecognitionManager(output: interactor)
        manager.registerType(NuanceRecognitionOperation)
        interactor.recognitionManager = manager
        
        viewController = TranscriptModuleVC(nibName: nil, bundle: nil)
        
        let router = TranscriptRouter(forPresenting: viewController, in: parentVC)
        
        presenter = TranscriptModulePresenter(view: viewController,
                                              logic: interactor,
                                              router: router)
    }
}