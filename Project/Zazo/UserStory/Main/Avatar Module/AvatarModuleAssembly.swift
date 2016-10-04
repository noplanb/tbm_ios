//
//  AvatarModuleAssembly.swift
//  Zazo
//
//  Created by Rinat on 04/10/2016.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import UIKit

protocol AvatarModuleInterface: NSObjectProtocol {
    func present(fromController viewController: UIViewController)
}

class AvatarModuleAssembly: NSObject, AvatarModuleInterface {
    func present(fromController fromViewController: UIViewController) {
        let viewController = AvatarViewController()
        fromViewController.presentViewController(viewController, animated: true, completion: nil)
    }
}
