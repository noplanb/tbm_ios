//
//  ZZAvatarViewController.swift
//  Zazo
//
//  Created by Rinat on 04/10/2016.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import UIKit

protocol AvatarUIInput: class {
    func show(items menuItems:[ZZMenuCellModel])
}

protocol AvatarUIOutput: class {
    
}

class AvatarViewController: UIViewController {

    let contentView = ZZMenuView()
    weak var eventHandler: AvatarUIOutput?
    
    let menuController = ZZMenuController()
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

     
    }

}

extension AvatarViewController: AvatarUIInput {
    func show(items menuItems:[ZZMenuCellModel]) {
        let storage = ANMemoryStorage()
        storage.addItems(menuItems, toSection: 0)
        menuController.storage = storage
    }
}
