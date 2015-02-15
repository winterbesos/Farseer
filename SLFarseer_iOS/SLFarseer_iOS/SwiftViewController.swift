//
//  SwiftViewController.swift
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/3/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

import UIKit

class SwiftViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        FSPFatal("this is a fatal error [Swift]")
        FSPError("this is a error [Swift]")
        FSPWarning("this is a warning [Swift]")
        FSPLog("this is a log [Swift]")
        FSPMinor("this is a minor log [Swift]")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }w
    */

}
