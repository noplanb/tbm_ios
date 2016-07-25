//
//  ConcurrentOperation.swift
//  Zazo
//
//  Created by Rinat Gabdullin on 28/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

public class ConcurrentOperation: NSOperation {
    
    // MARK: - Types
    
    enum State {
        case Ready, Executing, Finished
        func keyPath() -> String {
            switch self {
            case Ready:
                return "isReady"
            case Executing:
                return "isExecuting"
            case Finished:
                return "isFinished"
            }
        }
    }
    
    // MARK: - Properties
    
    var state = State.Ready {
        willSet {
            willChangeValueForKey(newValue.keyPath())
            willChangeValueForKey(state.keyPath())
        }
        didSet {
            didChangeValueForKey(oldValue.keyPath())
            didChangeValueForKey(state.keyPath())
        }
    }
    
    // MARK: - NSOperation
    
    override public var ready: Bool {
        return super.ready && state == .Ready
    }
    
    override public var executing: Bool {
        return state == .Executing
    }
    
    override public var finished: Bool {
        return state == .Finished
    }
    
    override public var asynchronous: Bool {
        return true
    }
    
}