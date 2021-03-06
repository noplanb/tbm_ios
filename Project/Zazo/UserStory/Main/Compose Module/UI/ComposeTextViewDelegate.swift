//
//  ComposeTextViewDelegate.swift
//  Zazo
//
//  Created by Rinat on 20/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

class ComposeTextViewDelegate: NSObject, UITextViewDelegate {
    
    let maximumFontSize = CGFloat(42)
    let minimumFontSize = CGFloat(18)
    var previousLength = 0
    var blockScrolling = false
    
    func textViewDidBeginEditing(textView: UITextView) {
        textView.font = UIFont.systemFontOfSize(maximumFontSize)
    }
    
    func textViewDidChange(textView: UITextView) {
        
        var viewSize = textView.bounds.size
        viewSize.height = 9999
        
        var fontSize = textView.text.characters.count > previousLength ? textView.font?.pointSize : maximumFontSize;
        var size = CGSize.zero
        
        repeat {
            textView.font = UIFont.systemFontOfSize(fontSize!)
            size = textView.sizeThatFits(viewSize)
            fontSize! -= 2
            
        } while textView.bounds.size.height < size.height && fontSize > minimumFontSize
        
        blockScrolling = fontSize > minimumFontSize
        previousLength = textView.text.characters.count
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if blockScrolling {
            scrollView.contentOffset = CGPoint.zero
        }

    }
}
