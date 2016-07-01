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
                            action: #selector(didPressClose))
        
        
        
        navigationBar.pushNavigationItem(self.navigationItem, animated: false)
        
        view.addSubview(navigationBar)
        
    }
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidAppear(animated: Bool) {
        add(transcript: "Copyright © 2016 No Plan B. All rights reserved", with: NSDate())
        
//        self.performSelector(#selector(viewDidAppear), withObject: true, afterDelay: 0.5)
    }
    
    // MARK: TranscriptUIInput
    
    func loading(ofType type:TranscriptUILoadingType, isVisible visible:Bool) {
        
    }
    
    func add(transcript text:String, with time:NSDate) {
        
        let item = TranscriptItemView()
        
        item.textLabel.text = text
        item.timeLabel.text = time.description
        
        self.contentView.stackView.addArrangedSubview(item)
        self.contentView.stackView.layoutIfNeeded()

        var frame = item.frame
        frame.size.height = 0
        item.frame = frame
        
        let animations = {
            item.setNeedsLayout()
            item.layoutIfNeeded()
        }
        
        UIView.animateWithDuration(0.5,
                                   delay: 0,
                                   usingSpringWithDamping: 0.7,
                                   initialSpringVelocity: 1,
                                   options: [],
                                   animations: animations,
                                   completion: nil)
        
    }
    
    func setVolumeEnabled(enabled:Bool) {
        
    }
    
    // MARK: Support
    
    func didPressClose() {
        self.output?.didTapCloseButton()
    }
}