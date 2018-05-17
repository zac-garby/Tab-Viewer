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

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
}

func readFile(_ path: URL) -> String? {
    let encodings: [String.Encoding] = [.utf8, .isoLatin1]
    
    for encoding in encodings {
        do {
            return try String(contentsOf: path, encoding: encoding)
        } catch {
            continue
        }
    }
    
    return nil
}

func songExists(title: String, artist: String, in context: NSManagedObjectContext) -> Bool {
    let request: NSFetchRequest<Tab> = Tab.fetchRequest()
    request.predicate = NSPredicate(format: "(title = %@) AND (artist = %@)", title, artist)
    
    do {
        let result = try context.fetch(request)
        return result.count > 0
    } catch {
        return false
    }
}
