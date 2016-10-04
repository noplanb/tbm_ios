//
//  AvatarPresenter.swift
//  Zazo
//
//  Created by Rinat on 04/10/2016.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import UIKit

class AvatarPresenter: NSObject {

    weak var interactor: ZZAvatarInteractor?
    weak var userInterface: AvatarUIInput?
    
    func menuItems() -> [ZZMenuCellModel] {
        let profilePhoto = ZZMenuCellModel(title: "Use profile photo", iconWithImageNamed: nil)
        profilePhoto.type = ZZMenuItemTypeUseAvatar
        
        let lastFrame = ZZMenuCellModel(title: "Use last frame of Zazo", iconWithImageNamed: nil)
        lastFrame.type = ZZMenuItemTypeUseLastFrame
        
        return [profilePhoto, lastFrame]
    }
}

extension AvatarPresenter: AvatarUIOutput {
    
}
