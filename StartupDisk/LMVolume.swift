//
//  LMVolume.swift
//  StartupDisk
//
//  Created by Felix Deimel on 04.06.14.
//  Copyright (c) 2014 Lemon Mojo. All rights reserved.
//

import Foundation

class LMVolume
{
    var path = ""
    var devicePath = ""
    var name = ""
    var bootable = false
    var bootableOSX = false
    
    init() { }
    
    class func volumeAtPath(path: String) -> LMVolume?
    {
        var name = ""
        var devicePath = ""
        var bootable = false
        var bootableOSX = false
        
        var volInfoDict = LMVolume.getVolumeInfoForPath(path)
        
        if (volInfoDict) {
            name = volInfoDict!.objectForKey("VolumeName") as String
            devicePath = volInfoDict!.objectForKey("DeviceNode") as String
            bootable = volInfoDict!.objectForKey("Bootable") as Bool
            
            if (bootable) {
                bootableOSX = LMVolume.getVolumeHasBootableOSXInstallationAtPath(path)
            }
        }
        
        var vol = LMVolume()
        vol.path = path
        vol.devicePath = devicePath
        vol.name = name
        vol.bootable = bootable
        vol.bootableOSX = bootableOSX
        
        return vol;
    }
    
    class func mountedLocalVolumes() -> [LMVolume]
    {
        var vols = [LMVolume]()
        var volPaths = LMVolume.mountedLocalVolumePaths()
        
        for path in volPaths {
            var vol = LMVolume.volumeAtPath(path)
            
            vols.append(vol!)
        }
        
        return vols
    }
    
    class func mountedLocalVolumesWithBootableOSXInstallations() -> [LMVolume]
    {
        var vols = [LMVolume]()
        var volPaths = LMVolume.mountedLocalVolumePaths()
        
        for path in volPaths {
            var vol = LMVolume.volumeAtPath(path)
            
            if (vol!.bootableOSX) {
                vols.append(vol!)
            }
        }
        
        return vols
    }
    
    class func mountedLocalVolumePaths() -> [String]
    {
        var volUrls = NSFileManager.defaultManager().mountedVolumeURLsIncludingResourceValuesForKeys(nil, options: NSVolumeEnumerationOptions.fromRaw(0)!)
        var volPaths = [String]()
        
        for url : AnyObject in volUrls {
            if (url is NSURL) {
                var path = (url as NSURL).path
                volPaths.append(path)
            }
        }
        
        return volPaths
    }

    class func getVolumeInfoForPath(path: String) -> NSDictionary?
    {
        var task = NSTask()
        
        task.launchPath = "/usr/sbin/diskutil"
        task.arguments = [ "info", "-plist", path ]
        
        var outputPipe = NSPipe.pipe()
        
        task.standardOutput = outputPipe
        
        task.launch()
        
        var data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        
        task.waitUntilExit()
        
        if (!data) {
            return nil
        }
        
        var dataDict = NSDictionary.dictionaryWithContentsOfData(data!)
        
        return dataDict
    }
    
    class func getVolumeHasBootableOSXInstallationAtPath(path: String) -> Bool
    {
        var task = NSTask()
        
        task.launchPath = "/usr/sbin/bless"
        task.arguments = [ "--info", path ]
        
        var outputPipe = NSPipe.pipe()
        
        task.standardOutput = outputPipe
        
        var fileHandle = outputPipe.fileHandleForReading
        
        task.launch()
        
        var data: NSData? = nil
        var dataStr = NSMutableString()
        
        while (true) {
            data = fileHandle.availableData
            
            if (!data || data!.length <= 0) {
                break
            }
            
            var tempString = NSString(data: data, encoding: NSUTF8StringEncoding)
            dataStr.appendString(tempString)
        }
        
        if (dataStr.length <= 0) {
            return false
        }
        
        return dataStr.containsString("Blessed System Folder is")
    }
    
    class func setStartupDiskAtPath(path: String) -> Bool
    {
        var task: STPrivilegedTask = STPrivilegedTask()
        
        task.setLaunchPath("/usr/sbin/bless")
        task.setArguments([ "--mount", path, "--setBoot" ])
        task.launch()
        task.waitUntilExit()
        
        return task.terminationStatus() == 0
    }
    
    class func startupDiskDevicePath() -> String
    {
        var task = NSTask()
        
        task.launchPath = "/usr/sbin/bless"
        task.arguments = [ "-getBoot" ]
        
        var outputPipe = NSPipe.pipe()
        
        task.standardOutput = outputPipe
        
        var fileHandle = outputPipe.fileHandleForReading
        
        task.launch()
        
        var data: NSData? = nil
        var dataStr = NSMutableString()
        
        while (true) {
            data = fileHandle.availableData
            
            if (!data || data!.length <= 0) {
                break
            }
            
            var tempString = NSString(data: data, encoding: NSUTF8StringEncoding)
            dataStr.appendString(tempString)
        }
        
        if (dataStr.length <= 0) {
            return ""
        }
        
        var finalDataStr = dataStr.trim()
        
        return finalDataStr
    }
    
    func isStartupDisk() -> Bool
    {
        var startupDisk = LMVolume.startupDiskDevicePath()
        
        if (startupDisk.isEmpty ||
            startupDisk == "") {
            return false
        }
        
        var found = self.devicePath == startupDisk
        
        return found
    }
    
    func setStartupDisk() -> Bool
    {
        return LMVolume.setStartupDiskAtPath(self.path)
    }
}