//
//  TranscriptModuleVC.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

class TranscriptVC: UIViewController, TranscriptUIInput {
    
    var output: TranscriptUIOutput?
    
    lazy var contentView = TranscriptView()
    
    // MARK: VC overrides
    
    override func viewDidLoad() {
        
        let navigationBar = contentView.navigationBar
        
        navigationItem.title = "Mary"
        
        navigationItem.leftBarButtonItem =
            UIBarButtonItem(title: "Close",
                            style: .Plain,
                            target: self,
                            action: #selector(didTapClose))
        
        navigationBar.pushNavigationItem(self.navigationItem, animated: false)
    
    }
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidAppear(animated: Bool) {

    }
    
    // MARK: TranscriptUIInput
    
    func loading(ofType type: TranscriptUILoadingType, isVisible visible: Bool) {
        
    }
    
    func add(transcript text: String, with time: NSDate) {
        
        let item = TranscriptItemView()
        
        item.textLabel.text = text
        item.timeLabel.text = time.description
        
        self.contentView.stackView.addArrangedSubview(item)
        self.contentView.stackView.layoutIfNeeded()

        item.alpha = 0
        
        let animations = {
            item.alpha = 1
        }
        
        UIView.animateWithDuration(0.5,
                                   delay: 0,
                                   usingSpringWithDamping: 0.7,
                                   initialSpringVelocity: 1,
                                   options: UIViewAnimationOptions.AllowUserInteraction,
                                   animations: animations,
                                   completion: nil)
        
    }
    
    func setVolumeEnabled(enabled: Bool) {
        
        let imageName = enabled ? "mute-off" : "mute-on"
        
        let image = UIImage(named: imageName,
                            inBundle: nil,
                            compatibleWithTraitCollection: nil)
        
        let button = UIBarButtonItem(image: image,
                                     style: .Plain,
                                     target: self,
                                     action: #selector(didTapMute))
        
        navigationItem.setRightBarButtonItem(button, animated: true)
    }
    
    func setThumbnail(image: UIImage) {
        self.contentView.thumb.image = image
    }
    
    // MARK: Support
    
    func didTapMute() {
        self.output?.didTapMuteButton()
    }
    
    func didTapClose() {
        self.output?.didTapCloseButton()
    }
}