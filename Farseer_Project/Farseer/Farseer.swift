//
//  Farseer.swift
//  SLFarseer
//
//  Created by Go Salo on 15/3/31.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

import Foundation

public func FSLog(log: String, fileName: String = __FILE__, functionName: String = __FUNCTION__, lineNumber: Int = __LINE__) {
    FS_DebugLog(log, .Log, fileName.lastPathComponent, functionName, UInt32(lineNumber))
}

public func FSWarning(log: String, fileName: String = __FILE__, functionName: String = __FUNCTION__, lineNumber: Int = __LINE__) {
    FS_DebugLog(log, .Warning, fileName.lastPathComponent, functionName, UInt32(lineNumber))
}

public func FSError(log: String, fileName: String = __FILE__, functionName: String = __FUNCTION__, lineNumber: Int = __LINE__) {
    FS_DebugLog(log, .Error, fileName.lastPathComponent, functionName, UInt32(lineNumber))
}

public func FSFatal(log: String, fileName: String = __FILE__, functionName: String = __FUNCTION__, lineNumber: Int = __LINE__) {
    FS_DebugLog(log, .Fatal, fileName.lastPathComponent, functionName, UInt32(lineNumber))
}

public func FSMinor(log: String, fileName: String = __FILE__, functionName: String = __FUNCTION__, lineNumber: Int = __LINE__) {
    FS_DebugLog(log, .Minor, fileName.lastPathComponent, functionName, UInt32(lineNumber))
}