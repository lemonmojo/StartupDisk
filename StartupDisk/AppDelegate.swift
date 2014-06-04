//
//  AppDelegate.swift
//  StartupDisk
//
//  Created by Felix Deimel on 04.06.14.
//  Copyright (c) 2014 Lemon Mojo. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    @IBOutlet var statusMenu: NSMenu
    var statusItem: NSStatusItem
    
    init()
    {
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(CGFloat(NSSquareStatusItemLength))
    }
    
    override func awakeFromNib()
    {
        self.statusItem.menu = self.statusMenu
        self.statusItem.highlightMode = true
    }

    func applicationDidFinishLaunching(aNotification: NSNotification?)
    {
        updateStatusItem()
    }

    func updateStatusItem()
    {
        self.statusItem.title = nil
        
        var icon = NSImage(named: "Icon")
        icon.size = NSSize(width: 16, height: 16)
        icon.setTemplate(true)
        
        self.statusItem.image = icon
    }
    
    func menuNeedsUpdate(menu: NSMenu!)
    {
        if (menu != self.statusMenu) {
            return
        }
        
        menu.removeAllItems()
        
        var vols = LMVolume.mountedLocalVolumesWithBootableOSXInstallations()
        var startupDiskDevicePath = LMVolume.startupDiskDevicePath()
        
        for vol in vols {
            var item = NSMenuItem(title: vol.name, action: "statusMenuItemVolume_Action:", keyEquivalent: "")
            item.representedObject = vol
            
            var icon = NSWorkspace.sharedWorkspace().iconForFile(vol.path)
            
            if (icon) {
                icon.size = NSSize(width: 16, height: 16)
            }
            
            item.image = icon
            
            if (vol.devicePath == startupDiskDevicePath) {
                item.state = NSOnState
            }
            
            menu.addItem(item)
        }
        
        menu.addItem(NSMenuItem.separatorItem())
        
        menu.addItem(NSMenuItem(title: "System Preferences", action: "statusMenuItemSystemPreferences_Action:", keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "About StartupDisk", action: "statusMenuItemAbout_Action:", keyEquivalent: ""))
        
        menu.addItem(NSMenuItem.separatorItem())
        
        menu.addItem(NSMenuItem(title: "Quit StartupDisk", action: "statusMenuItemQuit_Action:", keyEquivalent: ""))
    }
    
    func statusMenuItemVolume_Action(sender: NSMenuItem)
    {
        var vol = sender.representedObject as LMVolume
        
        if (vol.setStartupDisk()) {
            var alert = NSAlert()
            
            alert.addButtonWithTitle("Restart")
            alert.addButtonWithTitle("Cancel")
            alert.messageText = "Do you want to restart the Computer?"
            alert.informativeText = NSString(format: "Your Computer will start up using %@.", vol.name)
            alert.alertStyle = NSAlertStyle.InformationalAlertStyle
            
            var response = alert.runModal()
            
            if (response == NSAlertFirstButtonReturn) {
                LMUtils.restartMac()
            }
        }
    }
    
    func statusMenuItemSystemPreferences_Action(sender: NSMenuItem)
    {
        NSWorkspace.sharedWorkspace().openURL(NSURL(fileURLWithPath: "/System/Library/PreferencePanes/StartupDisk.prefPane"))
    }
    
    func statusMenuItemAbout_Action(sender: NSMenuItem)
    {
        NSApp.orderFrontStandardAboutPanel(self)
        NSApp.activateIgnoringOtherApps(true)
    }
    
    func statusMenuItemQuit_Action(sender: NSMenuItem)
    {
        NSApp.terminate(self)
    }
}