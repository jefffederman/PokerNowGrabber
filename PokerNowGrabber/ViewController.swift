//
//  ViewController.swift
//  PokerNowGrabber
//
//  Created by PJ Gray on 7/9/20.
//  Copyright © 2020 Say Goodnight Software. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var game: GameConnection?
    var controller: NSWindowController?
    var running: Bool = false
    
    @IBOutlet weak var heroNameTextField: NSTextField!
    @IBOutlet weak var grabHandsButton: NSButton!
    @IBOutlet weak var dptCookieTextField: NSTextField!
    @IBOutlet weak var nptCookieTextField: NSTextField!
    @IBOutlet weak var handsOutputDirTextField: NSTextField!
    @IBOutlet weak var gameURLTextField: NSTextField!
    @IBOutlet weak var multiplierTextField: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.heroNameTextField.stringValue = UserDefaults.standard.string(forKey: "heroName") ?? ""
        self.dptCookieTextField.stringValue = UserDefaults.standard.string(forKey: "dpt") ?? ""
        self.nptCookieTextField.stringValue = UserDefaults.standard.string(forKey: "npt") ?? ""
        self.handsOutputDirTextField.stringValue = UserDefaults.standard.string(forKey: "outputDirectory") ?? ""
        self.gameURLTextField.stringValue = UserDefaults.standard.string(forKey: "gameURL") ?? ""
        
        let multiplier = UserDefaults.standard.double(forKey: "multiplier")
        self.multiplierTextField.doubleValue = multiplier != 0.0 ? multiplier : 1.0
    }

    @IBAction func startGrabbingClicked(_ sender: Any) {
        
        if self.running {
            self.game = nil
            self.grabHandsButton.title = "Start grabbing hands"
            self.running = false
        } else {
            UserDefaults.standard.set(self.gameURLTextField.stringValue, forKey: "gameURL")
            UserDefaults.standard.set(self.heroNameTextField.stringValue, forKey: "heroName")
            UserDefaults.standard.set(self.dptCookieTextField.stringValue, forKey: "dpt")
            UserDefaults.standard.set(self.nptCookieTextField.stringValue, forKey: "npt")
            UserDefaults.standard.set(self.handsOutputDirTextField.stringValue, forKey: "outputDirectory")
            UserDefaults.standard.set(self.multiplierTextField.doubleValue, forKey: "multiplier")

            UserDefaults.standard.synchronize()
            
            self.game = GameConnection(gameIdOrURL: self.gameURLTextField.stringValue, heroName: self.heroNameTextField.stringValue, npt: self.nptCookieTextField.stringValue, dpt: self.dptCookieTextField.stringValue, handHistoryDirectory: self.handsOutputDirTextField.stringValue, multiplier: self.multiplierTextField.doubleValue)

            if let info = CGWindowListCopyWindowInfo(.optionAll, kCGNullWindowID) as? [[ String : Any]] {
                for dict in info {
                    if let ownerName = dict["kCGWindowOwnerName"] as? String, ownerName.contains("Chrome"), let rect = dict["kCGWindowBounds"] as? [String:Any], let height = rect["Height"] as? Int, let width = rect["Width"] as? Int, let x = rect["X"] as? Int, let y = rect["Y"] as? Int, height > 100 {
                        DispatchQueue.main.async {
                            let newFrame = CGRect(x: x - 300, y: y, width: width + 600, height: height)

                            let window = CustomWindow(contentRect: newFrame, styleMask: [.borderless], backing: .buffered, defer: false)
                            let gameId = self.gameURLTextField.stringValue.replacingOccurrences(of: "https://www.pokernow.club/games/", with: "")
                            window.title = "PokerNowGrabber - Table: \(gameId)"
                            self.controller = NSWindowController(window: window)
                            self.controller?.showWindow(self)

                        }
                    }
                }
            }
            
            self.grabHandsButton.title = "Stop grabbing hands"
            self.running = true
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

