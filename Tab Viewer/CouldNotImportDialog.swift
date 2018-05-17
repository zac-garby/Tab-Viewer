//
//  CouldNotImportDialog.swift
//  Tab Viewer
//
//  Created by Zac Garby on 11/05/2018.
//  Copyright © 2018 Zac Garby. All rights reserved.
//

import Cocoa

class CouldNotImportDialog: NSViewController {
    @IBOutlet weak var filenameLabel: NSTextField!
    var filename: String!
    
    override func viewWillAppear() {
        view.window?.styleMask.remove(.resizable)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filenameLabel.stringValue = filename
    }
    
    @IBAction func skip(_ sender: Any) {
        dismiss(nil)
    }
}
