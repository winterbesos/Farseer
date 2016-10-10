//
//  FarseerSupport.swift
//  Reco
//
//  Created by Salo on 2016/10/10.
//  Copyright © 2016年 eitdesign. All rights reserved.
//

import Farseer

public func FSLog(log: String, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    FS_DebugLog(kDefaultLogCode, log, .log, [:], fileName, functionName, UInt32(lineNumber))
}

public func FSWarning(log: String, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    FS_DebugLog(kDefaultLogCode, log, .warning, [:], fileName, functionName, UInt32(lineNumber))
}

public func FSError(code: Int, domain: String, info: [String: String], fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    FS_DebugLog(code, domain, .error, info, fileName, functionName, UInt32(lineNumber))
}

public func FSFatal(log: String, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    FS_DebugLog(kDefaultLogCode, log, .fatal, [:], fileName, functionName, UInt32(lineNumber))
}

public func FSMinor(log: String, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    FS_DebugLog(kDefaultLogCode, log, .minor, [:], fileName, functionName, UInt32(lineNumber))
}

public func FSCLog(condition: Bool, log: String, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    if condition { FS_DebugLog(kDefaultLogCode, log, .log, [:], fileName, functionName, UInt32(lineNumber)) }
}

public func FSCWarning(condition: Bool, log: String, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    if condition { FS_DebugLog(kDefaultLogCode, log, .warning, [:], fileName, functionName, UInt32(lineNumber)) }
}

public func FSCError(condition: Bool, code: Int, domain: String, info: [String: String], fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    if condition { FS_DebugLog(code, domain, .error, info, fileName, functionName, UInt32(lineNumber)) }
}

public func FSCFatal(condition: Bool, log: String, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    if condition { FS_DebugLog(kDefaultLogCode, log, .fatal, [:], fileName, functionName, UInt32(lineNumber)) }
}

public func FSCMinor(condition: Bool, log: String, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    if condition { FS_DebugLog(kDefaultLogCode, log, .minor, [:], fileName, functionName, UInt32(lineNumber)) }
}
