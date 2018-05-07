//
//  DeletePopoverViewController.swift
//  Tab Viewer
//
//  Created by Zac Garby on 07/05/2018.
//  Copyright © 2018 Zac Garby. All rights reserved.
//

import Cocoa

class DeletePopoverViewController: NSViewController {
    @IBOutlet weak var deleteChordsCheckbox: NSButton!
    @IBOutlet weak var deleteTabCheckbox: NSButton!
    
    var previous: ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(nil)
    }
    
    @IBAction func performDeletion(_ sender: Any) {
        let deleteChords = deleteChordsCheckbox.state == .on
        let deleteTab = deleteTabCheckbox.state == .on
        
        delete(chords: deleteChords, tab: deleteTab)
    }
    
    func delete(chords: Bool, tab: Bool) {
        guard let idToDelete = previous?.selectedTabID else {
            print("Could not delete")
            return
        }
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        if chords && !tab {
            
        } else if tab && !chords {
            
        } else if tab && chords {
            context.delete(context.object(with: idToDelete))
        }
        
        do {
            try context.save()
        } catch {
            print("Could not save context!")
        }
        
        if let prev = previous {
            prev.tableView.reloadData()
            
            if let fetched = prev.getTabs(from: context) {
                prev.arrayController.content = fetched
            }
        }
        
        dismiss(nil)
    }
}
