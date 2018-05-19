//
//  ImportFolderViewController.swift
//  Tab Viewer
//
//  Created by Zac Garby on 06/05/2018.
//  Copyright © 2018 Zac Garby. All rights reserved.
//

import Cocoa

typealias Data = (title: String, artist: String, type: String, data: String)

class ImportFolderViewController: NSViewController {
    @IBOutlet weak var folderPath: NSTextField!
    @IBOutlet weak var filenameFormatTextField: NSTextField!
    @IBOutlet weak var replacePunctCheck: NSButton!
    @IBOutlet weak var autoCapCheck: NSButton!
    @IBOutlet weak var noDupCheck: NSButton!
    @IBOutlet weak var removeExtCheck: NSButton!
    @IBOutlet weak var nonMatchBehaviourDropdown: NSPopUpButton!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var defaultTypePopup: NSPopUpButton!
    @IBOutlet weak var defaultArtistPopup: NSTextField!
    @IBOutlet weak var defaultTitlePopup: NSTextField!
    
    private var currentFile: URL?
    
    override func viewWillAppear() {
        view.window?.styleMask.remove(.resizable)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressBar.isHidden = true
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(nil)
    }
    
    @IBAction func selectFolder(_ sender: Any) {
        if let folder = selectFile(title: "Choose a folder", files: false, dirs: true) {
            folderPath.stringValue = folder.path
        }
    }
    
    @IBAction func importFolder(_ sender: Any) {
        let folder = folderPath.stringValue
        
        guard let files = getFiles(in: folder) else {
            print("Couldn't get files from folder")
            return
        }
        
        progressBar.isHidden = false
        progressBar.maxValue = Double(files.count)
        
        var allData: [Data] = []
        
        for file in files {
            let url = URL(fileURLWithPath: file)
            currentFile = url
            
            if !FileManager.default.fileExists(atPath: url.path) {
                let alert = NSAlert()
                alert.messageText = "No file exists at \(url.lastPathComponent)"
                alert.runModal()
                continue
            }
            
            var (data, reason) = importFile(url, removeExtension: removeExtCheck.state == .on)
            if data != nil {
                applyTransformations(&data!,
                                     removePunctuation: replacePunctCheck.state == .on,
                                     autoCapitalise: autoCapCheck.state == .on)
                
                allData.append(data!)
            } else {
                print("could not import \(url.path) due to a problem with: \(String(describing: reason))")
                performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "CouldNotImport"), sender: self)
            }
            
            progressBar.doubleValue += 1
        }
        
        print(allData)
        
        progressBar.isHidden = true
    }
    
    func getFiles(in path: String) -> [String]? {
        guard let paths = try? FileManager.default.contentsOfDirectory(atPath: path) else {
            return nil
        }
        
        return paths.map { content in
            (path as NSString).appendingPathComponent(content)
        }
    }
    
    func importFile(_ url: URL, removeExtension: Bool) -> (Data?, String?) {
        let format = filenameFormatTextField.stringValue
        
        var filename = url.lastPathComponent
        guard let contents = readFile(url) else {
            return (nil, "read")
        }
        
        if removeExtension {
            filename = URL(fileURLWithPath: filename).deletingPathExtension().lastPathComponent
        }
        
        guard let (type, artist, title) = parseFilename(format: format, filename: filename) else {
            performSegue(
                withIdentifier: NSStoryboardSegue.Identifier(rawValue: "CouldNotImport"),
                sender: self)
            
            return (nil, "parse")
        }
        
        return ((title: title, artist: artist, type: type, contents), nil)
    }
    
    // Transforms a piece of data by the specified flags, and modifies the data in place.
    func applyTransformations(_ data: inout Data,
                              removePunctuation: Bool,
                              autoCapitalise: Bool) {

        if removePunctuation {
            data.artist = data.artist.replacingOccurrences(of: "-", with: " ")
                                     .replacingOccurrences(of: "_", with: " ")
            
            data.title = data.title.replacingOccurrences(of: "-", with: " ")
                                   .replacingOccurrences(of: "_", with: " ")
        }
        
        if autoCapitalise {
            data.artist = data.artist.capitalized
            data.title = data.title.capitalized
        }
    }
    
    // Tokenizes a format string, so $type_$artist would become ["$type", "_", "$artist"]
    func tokenize(format: String) -> [String] {
        let vars = ["$type", "$artist", "$title"]
        var str = format
        var parsed: [String] = []
        var index = 0
        var buffer = ""
        
        while index < str.count {
            for varStr in vars {
                if str.hasPrefix(varStr) {
                    // Found a variable, push buffer and variable string
                    if buffer.count > 0 { parsed.append(buffer) }
                    parsed.append(varStr)
                    buffer = ""
                    str.removeFirst(varStr.count)
                    break
                }
            }
            
            if str.count > 0 {
                buffer.append(str[0])
                str.removeFirst()
            }
            
            index += 1
        }
        
        if buffer != "" {
            parsed.append(buffer)
        }
        
        return parsed
    }
    
    func parseFilename(format: String, filename f: String) -> (type: String, artist: String, title: String)? {
        var filename = f
        var type = "chords"
        if defaultTypePopup.indexOfSelectedItem == 0 {
            type = "tab"
        }
        
        var artist = "Unknown"
        if defaultArtistPopup.stringValue.count > 0 {
            type = defaultArtistPopup.stringValue
        }
        
        var title = "Unknown"
        if defaultTitlePopup.stringValue.count > 0 {
            type = defaultTitlePopup.stringValue
        }
        
        let tokens = tokenize(format: format)
        
        for (i, cur) in tokens.enumerated() {
            var next: String
            if i + 1 < tokens.count {
                next = tokens[i + 1]
            } else {
                next = "\0"
            }
            
            if cur.hasPrefix("$") {
                // Is variable
                let stop = next[0]
                var buffer = ""
                var index = 0
                
                while index < filename.count && filename[index] != stop {
                    let char = filename[index]
                    buffer.append(char)
                    index += 1
                }
                
                switch cur {
                case "$type":
                    buffer = buffer.lowercased()
                    if buffer == "chords" || buffer == "chord" {
                        type = "chords"
                    } else if buffer == "tabs" || buffer == "tab" {
                        type = "tab"
                    } else {
                        return nil
                    }
                case "$artist":
                    artist = buffer
                case "$title":
                    title = buffer
                default: break
                }
                
                filename.removeFirst(buffer.count)
            } else {
                // Isn't variable
                if filename.hasPrefix(cur) {
                    // Skip past non-variable sections
                    filename.removeFirst(cur.count)
                } else {
                    return nil
                }
            }
        }
        
        if filename.count > 0 {
            // There are still characters left, so it wasn't a perfect match
            return nil
        }
        
        return (type: type, artist: artist, title: title)
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let destination = segue.destinationController as? CouldNotImportDialog else { return }
        destination.filename = currentFile?.lastPathComponent
    }
}
