//
//  ImportFileViewController.swift
//  Tab Viewer
//
//  Created by Zac Garby on 06/05/2018.
//  Copyright © 2018 Zac Garby. All rights reserved.
//

import Cocoa

class ImportFileViewController: NSViewController {
    @IBOutlet weak var tabPathTextField: NSTextField!
    @IBOutlet weak var chordsPathTextField: NSTextField!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var artistTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(nil)
    }
    
    @IBAction func selectTabPath(_ sender: Any) {
        if let url = selectFile(title: "Select a tab file", files: true, dirs: false) {
            tabPathTextField.stringValue = url.path
        }
    }
    
    @IBAction func selectChordsPath(_ sender: Any) {
        if let url = selectFile(title: "Select a chord file", files: true, dirs: false) {
            chordsPathTextField.stringValue = url.path
        }
    }
    
    @IBAction func importFiles(_ sender: Any) {
        let tabPath = tabPathTextField.stringValue
        let chordsPath = chordsPathTextField.stringValue
        
        var tab: String
        var chords: String
        
        do {
            if tabPath != "" {
                tab = try String.init(contentsOfFile: tabPath)
            } else {
                tab = "Nothing here..."
            }
            
            if chordsPath != "" {
                chords = try String.init(contentsOfFile: chordsPath)
            } else {
                chords = "Nothing here..."
            }
        } catch {
            print("Could not read file!")
            return
        }
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Tab", in: context)
        let newTab = NSManagedObject(entity: entity!, insertInto: context)
        newTab.setValue(titleTextField.stringValue, forKey: "title")
        newTab.setValue(artistTextField.stringValue, forKey: "artist")
        newTab.setValue(tab, forKey: "data_tab")
        newTab.setValue(chords, forKey: "data_chords")
        
        do {
            try context.save()
        } catch {
            print("Could not save context!")
        }
        
        self.dismiss(nil)
    }
}
