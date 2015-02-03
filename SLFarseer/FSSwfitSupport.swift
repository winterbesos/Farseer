//
//  FSSwfitSupport.swift
//  SLFarseer
//
//  Created by Go Salo on 2/3/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

import Foundation

func FSFatal(log: String) {
    FS_DebugLog(log, Fatal)
}

func FSError(log: String) {
    FS_DebugLog(log, Error)
}

func FSWarning(log: String) {
    FS_DebugLog(log, Warning)
}

func FSLog(log: String) {
    FS_DebugLog(log, Log)
}

func FSMinor(log: String) {
    FS_DebugLog(log, Minor)
}