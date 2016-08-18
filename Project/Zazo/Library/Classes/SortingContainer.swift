//
//  SortingContainer.swift
//  Zazo
//
//  Created by Rinat on 18/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

public protocol Sortable: Equatable {
    func value() -> Int
}

extension RecognitionResult: Sortable {
    public func value() -> Int {
        return Int(self.date.timeIntervalSince1970)
    }
}

class SortingContainer<T: Sortable> {
    
    var sorted: [T] {
        return _sorted
    }
    
    private var _sorted = [T]()
    
    func add(item item: T) {
        let index = _sorted.indexOf { $0.value() > item.value() } ?? _sorted.count
        _sorted.insert(item, atIndex: index)
    }
}
