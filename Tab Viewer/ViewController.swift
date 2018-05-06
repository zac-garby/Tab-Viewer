//
//  ViewController.swift
//  Tab Viewer
//
//  Created by Zac Garby on 05/05/2018.
//  Copyright © 2018 Zac Garby. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var arrayController: NSArrayController!
    
    var font: NSFont = NSFont.userFixedPitchFont(ofSize: 11)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let row = tableView.selectedRow
        guard let data = arrayController.content as? [Tab] else {
            return
        }
        
        if !data.indices.contains(row) { return }
        
        let tab = data[row]
        
        if let chords = tab.data_chords {
            setText(value: chords)
        }
    }
}
