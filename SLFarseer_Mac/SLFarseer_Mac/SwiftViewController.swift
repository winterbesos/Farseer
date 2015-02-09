//
//  SwiftViewController.swift
//  SLFarseer
//
//  Created by Go Salo on 2/3/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

import Cocoa

class SwiftViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        FSPFatal("this is a fatal error [Swift]")
        FSPError("this is a error [Swift]")
        FSPWarning("this is a warning [Swift]")
        FSPLog("this is a log [Swift]")
        FSPMinor("this is a minor log [Swift]")
    }
    
}
