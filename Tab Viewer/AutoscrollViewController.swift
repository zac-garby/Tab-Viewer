//
//  AutoscrollViewController.swift
//  Tab Viewer
//
//  Created by Zac Garby on 07/05/2018.
//  Copyright © 2018 Zac Garby. All rights reserved.
//

import Cocoa

class AutoscrollViewController: NSViewController {
    @IBOutlet weak var slider: NSSlider!
    @IBOutlet weak var button: NSButton!
    
    var scrolling: Bool = false
    var previous: ViewController?
    var timer: Timer?
    
    override func viewWillAppear() {
        view.window?.styleMask.remove(.resizable)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startTimer()
    }
    
    override func viewWillDisappear() {
        timer?.invalidate()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(
            withTimeInterval: TimeInterval(0.02),
            repeats: true,
            block: { timer in
                guard self.scrolling else { return }
                guard let scrollView = self.previous?.scrollView else { return }
                
                let rect = scrollView.contentView.visibleRect
                
                guard rect.maxY < scrollView.contentView.documentRect.height else { return }
                
                scrollView.contentView.scroll(to: NSPoint(
                    x: 0,
                    y: rect.minY + CGFloat(self.slider.floatValue)))
            })
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.view.window?.close()
    }
    
    @IBAction func stopOrStart(_ sender: Any) {
        scrolling = !scrolling
        
        if scrolling {
            button.title = "Stop"
        } else {
            button.title = "Start"
        }
    }
}
