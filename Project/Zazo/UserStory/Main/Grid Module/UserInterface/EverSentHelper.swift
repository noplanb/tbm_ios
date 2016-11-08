//
//  EverSentHelper.swift
//  Zazo
//
//  Created by Rinat on 30/05/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

public class EverSentHelper: NSObject
{
    private let sendMessageCounterKey = "sendMessageCounterKey"
    
    static let sharedInstance = EverSentHelper()
    
    public var everSentCount: Int
    {
        return everSentFriends.count
    }
    
    private var everSentFriends = [String]()
    
    override init()
    {
        super.init()
        
        guard let loadedArray = NSUserDefaults.standardUserDefaults().arrayForKey(sendMessageCounterKey) else
        {
            return
        }
        
        for loadedItem in loadedArray
        {
            if let key = loadedItem as? String
            {
                everSentFriends.append(key)
            }
        }
    }
    
    func isEverSentToFriend(friendKey: String) -> Bool
    {
        return everSentFriends.contains(friendKey)
    }
    
    func addToEverSent(friendKey: String)
    {
        
        guard !friendKey.isEmpty else
        {
            return
        }

        guard !isEverSentToFriend(friendKey) else
        {
            return
        }
        
        everSentFriends.append(friendKey)
        saveToUserDefaults()
    }
    
    func clear()
    {
        everSentFriends = []
        saveToUserDefaults()
    }
    
    private func saveToUserDefaults()
    {
        NSUserDefaults.standardUserDefaults().setObject(everSentFriends, forKey: sendMessageCounterKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}
