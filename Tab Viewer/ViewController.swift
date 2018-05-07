//
//  ViewController.swift
//  Tab Viewer
//
//  Created by Zac Garby on 05/05/2018.
//  Copyright © 2018 Zac Garby. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var textView: NSTextView!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var tabTypeControl: NSSegmentedControl!
    @IBOutlet var arrayController: NSArrayController!
    
    var font: NSFont = NSFont.userFixedPitchFont(ofSize: 11)!
    var selectedTabID: NSManagedObjectID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadData),
            name: NSNotification.Name(rawValue: "dataUpdated"),
            object: nil)
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Fetch tabs from CoreData
        if let fetched = getTabs(from: context) {
            arrayController.content = fetched
        }
        
        // Set up the table view to display the list of tabs
        tableView.delegate = self
        
        onTextChange()
        
        // Set up the text view to display tabs on
        textView.delegate = self
        textView.textContainerInset = NSMakeSize(15, 20)
        textView.isAutomaticDataDetectionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticDataDetectionEnabled = false
        textView.isAutomaticLinkDetectionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        
        // Reload the tab to set selectedTabID
        reloadTab()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue: "dataUpdated"),
            object: nil)
    }
    
    // Fetches a list of tabs from the CoreData database
    func getTabs(from context: NSManagedObjectContext) -> [Tab]? {
        do {
            return try context.fetch(Tab.fetchRequest())
        } catch {
            print("Fetching error, \(error)")
        }
        
        return nil
    }
    
    @objc func reloadData() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        if let fetched = getTabs(from: context) {
            arrayController.content = fetched
        }
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let ident = segue.identifier else { return }
        
        if ident.rawValue == "DeletePopover" {
            guard let destination = segue.destinationController as? DeletePopoverViewController else {
                return
            }
            
            destination.previous = self
        }
    }
    
    @IBAction func changeTabType(_ sender: NSSegmentedControl) {
        reloadTab()
    }
}

extension ViewController: NSTextViewDelegate {
    // Every time the text is changed, the font of the entire
    // text view is set to a monospaced 13pt font. This is a
    // bit of a hack.
    func textDidChange(_ notification: Notification) {
        onTextChange()
    }
    
    func onTextChange() {
        textView.textStorage?.addAttribute(
            .font,
            value: font as Any,
            range: NSMakeRange(0, textView.string.endIndex.encodedOffset)
        )
    }
    
    func setText(value: String) {
        textView.string = value
        onTextChange()
    }
}

extension ViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        reloadTab()
    }
    
    func reloadTab() {
        let row = tableView.selectedRow
        guard let data = arrayController.content as? [Tab] else {
            return
        }
        
        if !data.indices.contains(row) { return }
        
        let tab = data[row]
        selectedTabID = tab.objectID
        
        if tabTypeControl.indexOfSelectedItem == 0 {
            if let chords = tab.data_chords {
                setText(value: chords)
            }
        } else {
            if let tabString = tab.data_tab {
                setText(value: tabString)
            }
        }
    }
}
