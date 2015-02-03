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

        FSFatal("this is a fatal error [Swift]")
        FSError("this is a error [Swift]")
        FSWarning("this is a warning [Swift]")
        FSLog("this is a log [Swift]")
        FSMinor("this is a minor log [Swift]")
    }
    
}
