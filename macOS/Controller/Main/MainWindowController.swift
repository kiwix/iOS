//
//  MainController.swift
//  macOS
//
//  Created by Chris Li on 8/22/17.
//  Copyright © 2017 Chris Li. All rights reserved.
//

import Cocoa
import SwiftyUserDefaults

class MainWindowController: NSWindowController {
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var loadingView: NSProgressIndicator!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.titleVisibility = .hidden
    }
    
    @IBAction func mainPageButtonTapped(_ sender: NSToolbarItem) {
        guard let split = contentViewController as? NSSplitViewController,
            let controller = split.splitViewItems.last?.viewController as? WebViewController else {return}
        controller.loadMainPage()
    }
    
    @IBAction func backForwardControlClicked(_ sender: NSSegmentedControl) {
        guard let split = contentViewController as? NSSplitViewController,
            let controller = split.splitViewItems.last?.viewController as? WebViewController else {return}
        if sender.selectedSegment == 0 {
            controller.webView.goBack()
        } else if sender.selectedSegment == 1 {
            controller.webView.goForward()
        }
    }
    
    @IBAction func openBook(_ sender: NSMenuItem) {
        let openPanel = NSOpenPanel()
        openPanel.showsHiddenFiles = false
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        
        openPanel.beginSheetModal(for: window!) { response in
            guard response == NSFileHandlingPanelOKButton else {return}
            let paths = openPanel.urls.map({$0.path})
            Defaults[.bookPaths] = paths
            ZimManager.shared.removeAllBook();
            ZimManager.shared.addBooks(paths: paths)
            
            guard let split = self.contentViewController as? NSSplitViewController,
                let searchController = split.splitViewItems.first?.viewController as? SearchController,
                let webController = split.splitViewItems.last?.viewController as? WebViewController else {return}
            searchController.clearSearch()
            webController.loadMainPage()
        }
    }
}

class WelcomeViewController: NSViewController {
    @IBAction func openBookButtonTapped(_ sender: NSButton) {
        
    }
}