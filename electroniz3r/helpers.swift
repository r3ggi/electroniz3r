//
//  definitions.swift
//  electroniz3r
//
//  Created by Wojciech Reguła on 17/01/2023.
//

import Foundation
import ArgumentParser
import AppKit

let ELECTRON_DEBUG_PORT: UInt16 = 13337

struct ElectronApp {
    var path: String
    var identifier: String
}

class ElectronAppSingleton {
    
    var pid: pid_t
    var webSocketDebuggerUrlString: String
    
    static var shared: ElectronAppSingleton = {
        let instance = ElectronAppSingleton()
        return instance
    }()
    
    
    private init() {
        pid = 0
        webSocketDebuggerUrlString = ""
    }
    
    func isFinishedLaunching() -> Bool {
        
        if let runningApp = NSRunningApplication(processIdentifier: self.pid) {
            return runningApp.isFinishedLaunching
        }
        return false
    }
}

extension String {
 
    var green: String {
        return "\u{001B}[0;32m\(self)\u{001B}[0;0m"
    }
    
    var red: String {
        return "\u{001B}[0;31m\(self)\u{001B}[0;0m"
    }
    
    var yellow: String {
        return "\u{001B}[0;33m\(self)\u{001B}[0;0m"
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

func waitMaximally10Seconds(myBlock:()->Bool) {
    let waitMaximally = 10.0 // seconds
    let start = DispatchTime.now().uptimeNanoseconds
    repeat {
        if myBlock() {
            break
        }
    } while (Double(DispatchTime.now().uptimeNanoseconds-start)/1_000_000_000)<waitMaximally
}

func executeCode(code: String) {
    WebSocketTaskConnectionSingleton.shared.connect()
    WebSocketTaskConnectionSingleton.shared.executeCodeInElectronApp(code: code)
    
    waitMaximally10Seconds {
        return WebSocketTaskConnectionSingleton.shared.didDebuggerRespond
    }
}

func prepareSwiftSelfieTaker() {
    do {
        if let swiftSelfieTakerData = Data(base64Encoded: swiftSelfieTakerB64Executable) {
            let swiftSelfieTakerPath = "/private/tmp/SwiftSelfieTaker"
            let swiftSelfieTakerURL = URL(filePath: swiftSelfieTakerPath)
            try swiftSelfieTakerData.write(to: swiftSelfieTakerURL)
            
            let fileManager = FileManager.default
            var fileAttributes = try fileManager.attributesOfItem(atPath: swiftSelfieTakerPath)
            if var permissions = fileAttributes[.posixPermissions] as? UInt16 {
                       permissions |= 0o111  // Set the executable bit
                       fileAttributes[.posixPermissions] = permissions
                       try fileManager.setAttributes(fileAttributes, ofItemAtPath: swiftSelfieTakerPath)
            }
        }
    } catch {
        print("Error: \(error.localizedDescription)")
        exit(-1)
    }
}
