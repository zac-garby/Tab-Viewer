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
    request.predicate = NSPredicate(
        format: "(title LIKE[cd] %@) AND (artist LIKE[cd] %@)",
        argumentArray: [title, artist])
    
    do {
        let result = try context.fetch(request)
        return result.count > 0
    } catch {
        print("error: \(error)")
        return false
    }
}

// adds a song to the database. Won't save the context, so do that yourself
func addSong(title: String, artist: String, type: String, content: String, in context: NSManagedObjectContext) throws {
    let request: NSFetchRequest<Tab> = Tab.fetchRequest()
    request.predicate = NSPredicate(
        format: "(title LIKE[cd] %@) AND (artist LIKE[cd] %@)",
        argumentArray: [title, artist, type])
    let result = try context.fetch(request)
    
    var tab: NSManagedObject
    
    if result.count > 0 {
        tab = result[0]
    } else {
        let entity = NSEntityDescription.entity(forEntityName: "Tab", in: context)
        tab = NSManagedObject(entity: entity!, insertInto: context)
    }
    
    tab.setValue(title, forKey: "title")
    tab.setValue(artist, forKey: "artist")
    
    if type == "chords" {
        tab.setValue(content, forKey: "data_chords")
        tab.setValue("Nothing here...", forKey: "data_tab")
    } else {
        tab.setValue(content, forKey: "data_tab")
        tab.setValue("Nothing here...", forKey: "data_chords")
    }
}
