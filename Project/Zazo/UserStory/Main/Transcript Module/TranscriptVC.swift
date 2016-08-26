//
//  TranscriptModuleVC.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

public class TranscriptVC: UIViewController, TranscriptUIInput {
    
    weak var output: TranscriptUIOutput?
    
    public lazy var contentView = TranscriptView()
    let loadingView = TranscriptItemView()
    
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
        
        loadingView.textLabel.text = "Converting Zazo to text..."
        
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        loadingIndicator.startAnimating()
        
        loadingView.iconView = loadingIndicator
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.contentView.scrollView.addGestureRecognizer(tapRecognizer)
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
    }
    
    func loading(ofType type: TranscriptUILoadingType, isVisible visible: Bool) {
        switch type {
        case .Transcript:
            setTranscriptAnimationVisible(visible)
            break
        }
    }
    
    func askRetry(completion: (Bool) -> ()) {
        
        let alertController = UIAlertController(title: "Recognition has failed",
                                                message: "If the error is repeating please try later",
                                                preferredStyle: .Alert)
        
        let handler: UIAlertAction -> Void = { completion($0.style == .Default) }
        
        alertController.addAction(UIAlertAction(title: "Try again", style: .Default, handler: handler))
        alertController.addAction(UIAlertAction(title: "Later", style: .Cancel, handler: handler))
        
        presentViewController(alertController, animated: true, completion: nil)
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
    
    func insertItem(text: String, index: UInt, time: NSDate) {
    
        let item = TranscriptItemView()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleItemTap(with:)))
        item.addGestureRecognizer(recognizer)
        
        let emptyText = "No recognized text"
        let noText = text.characters.count == 0
        
        if noText {
            item.textLabel.font = UIFont.italicSystemFontOfSize(item.textLabel.font.pointSize)
        }
        
        item.textLabel.text = noText ? emptyText : text
        item.timeLabel.text = time.zz_formattedDate()
        
//        var index = index
        
//        if (animating) {
//            index -= 1
//        }
        
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
    
    func clearItems() {
        for view in contentView.stackView.arrangedSubviews {
            contentView.stackView.removeArrangedSubview(view)
        }
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
    
    func didTapBackground() {
        self.output?.didTapBackground()
    }
    
    func handleItemTap(with recognizer: UIGestureRecognizer) {
        guard let view = recognizer.view else {
            return
        }
        
        guard let index = contentView.stackView.arrangedSubviews.indexOf(view) else {
            return
        }
        
        self.output?.didTapAtItem(at: index)
    }
}