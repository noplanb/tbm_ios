//
//  TranscriptModuleVC.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

public class TranscriptVC: UIViewController, TranscriptUIInput {
    
    var output: TranscriptUIOutput?
    
    public lazy var contentView = TranscriptView()
    
    let loadingView = TranscriptItemView()
    
    let dateFormater = NSDateFormatter()
    
    var animating = false {
        didSet {
            _setTranscriptAnimationVisible(animating)
        }
    }
    
    // MARK: VC overrides
    
    override public func viewDidLoad() {
        
        let navigationBar = contentView.navigationBar
        
        navigationItem.leftBarButtonItem =
            UIBarButtonItem(title: "Close",
                            style: .Plain,
                            target: self,
                            action: #selector(didTapClose))
        
        navigationBar.pushNavigationItem(self.navigationItem, animated: false)
    
        dateFormater.dateStyle = .MediumStyle
        dateFormater.timeStyle = .MediumStyle
     
        loadingView.textLabel.text = "Converting Zazo to text..."
        
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        loadingIndicator.startAnimating()
        
        loadingView.iconView = loadingIndicator
    }
    
    override public func loadView() {
        view = contentView
    }
    
    // MARK: TranscriptUIInput
    
    func showPlayer(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.playerView = view
    }
    
    func showPlaybackControl(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false 
        contentView.playbackIndicator = view
        
        if let indicator = view as? PlaybackIndicator {
            indicator.invertedColorTheme = true
        }
    }
    
    func loading(ofType type: TranscriptUILoadingType, isVisible visible: Bool) {
        switch type {
        case .Transcript:
            setTranscriptAnimationVisible(visible)
            break
        }
    }
    
    func setTranscriptAnimationVisible(flag: Bool) {
        animating = flag
    }
    
    func _setTranscriptAnimationVisible(flag: Bool) {
        
        let updateBlock = {
            
            if flag {
                self.contentView.stackView.addArrangedSubview(self.loadingView)
            }
            else {
                self.contentView.stackView.removeArrangedSubview(self.loadingView)
            }
        }
        
        UIView.animateWithDuration(0.5, animations: updateBlock)
    }
    
    func add(transcript text: String, with time: NSDate) {
        
        let item = TranscriptItemView()
        
        item.textLabel.text = text
        item.timeLabel.text = dateFormater.stringFromDate(time)
        
        var index = UInt(contentView.stackView.arrangedSubviews.count)
        
        if (animating) {
            index -= 1
        }
        
        contentView.stackView.insertArrangedSubview(item, atIndex: index)
        contentView.stackView.layoutIfNeeded()

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
    
    func setFriendName(name: String) {
        self.navigationItem.title = name
    }
    
    // MARK: Support
    
    func didTapMute() {
        self.output?.didTapMuteButton()
    }
    
    func didTapClose() {
        self.output?.didTapCloseButton()
    }
}