//
//  LMUtils.swift
//  StartupDisk
//
//  Created by Felix Deimel on 04.06.14.
//  Copyright (c) 2014 Lemon Mojo. All rights reserved.
//

import Foundation

class LMUtils
{
    class func restartMac()
    {
        var scriptAction = "restart"
        var scriptSource = NSString(format: "tell application \"Finder\" to %@", scriptAction)
        var appleScript = NSAppleScript(source: scriptSource)
        
        appleScript.executeAndReturnError(nil)
    }
}

extension NSString
{
    func containsString(substring: NSString) -> Bool
    {
        var range: NSRange = self.rangeOfString(substring)
        var found: Bool = range.location != NSNotFound
        
        return found
    }
    
    func trim() -> NSString
    {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}

extension NSDictionary
{
    class func dictionaryWithContentsOfData(data: NSData) -> NSDictionary?
    {
        let immutability: CFOptionFlags = 0
        
        var plist: CFPropertyListRef = CFPropertyListCreateFromXMLData(
            kCFAllocatorDefault, data,
            immutability, // kCFPropertyListImmutable
            nil
        ).takeUnretainedValue()
        
        return plist as? NSDictionary
    }
}

