//
//  MenuItem.swift
//  Zazo
//
//  Created by Rinat on 16/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

@objc enum MenuItemType: Int {
    case ConvertToText
    case PlayFullscreen
    case SendText
    
    func title() -> String {
        switch self {
        case .ConvertToText: return "Convert to text"
        case .PlayFullscreen: return "Play fullscreen"
        case .SendText: return "Send text"
        }
    }
        
    func iconFilename() -> String {
        switch self {
        case .ConvertToText: return "transcript-icon"
        case .PlayFullscreen: return "fullscreen-icon"
        case .SendText: return "message-icon"
        }
    }
}

@objc public class MenuItem: NSObject {
    
    let type: MenuItemType
    var title: String
    var icon: UIImage?
    
    init(type: MenuItemType) {
        self.type = type
        self.title = type.title()
        self.icon = UIImage(named: type.iconFilename())
    }
}