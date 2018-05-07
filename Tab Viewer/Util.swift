//
//  Util.swift
//  Tab Viewer
//
//  Created by Zac Garby on 06/05/2018.
//  Copyright © 2018 Zac Garby. All rights reserved.
//

import Cocoa

func selectFiles(title: String, files: Bool, dirs: Bool, multiselection: Bool) -> [URL]? {
    let dialog = NSOpenPanel()
    dialog.title = title
    dialog.showsResizeIndicator = true
    dialog.showsHiddenFiles = false
    dialog.canChooseFiles = files
    dialog.canChooseDirectories = dirs
    dialog.allowsMultipleSelection = multiselection
    
    if dialog.runModal() == .OK {
        let result = dialog.urls
        return result
    }
    
    return nil
}

func selectFile(title: String, files: Bool, dirs: Bool) -> URL? {
    guard let urls = selectFiles(title: title, files: files, dirs: dirs, multiselection: false) else {
        return nil
    }
    
    return urls[0]
}
