//
//  checkvulnerable.swift
//  electroniz3r
//
//  Created by Wojciech Reguła on 17/01/2023.
//

import Foundation
import AppKit

func launchApplicationWithInspectArgument(path: String) {
    let url = URL(filePath: path)
    let openConfiguration = NSWorkspace.OpenConfiguration()
    openConfiguration.arguments = ["--inspect=\(ELECTRON_DEBUG_PORT)"]
    
    let workspace = NSWorkspace.shared
    
    workspace.openApplication(at: url, configuration: openConfiguration) { nsRunningApp, error in
        if let app = nsRunningApp {
            ElectronAppSingleton.shared.pid = app.processIdentifier
        }
    }
}

func isVulnerable(path: String) -> Bool {
    
    var vulnerableStatus = false
    
    if isPortOpen(port: ELECTRON_DEBUG_PORT) {
        print("Error: Something already listens on debug port - \(ELECTRON_DEBUG_PORT)".red)
        print("-> check it with `lsof -i tcp:\(ELECTRON_DEBUG_PORT)`".red)
        return vulnerableStatus
    }
    
    launchApplicationWithInspectArgument(path: path)

    waitMaximally10Seconds {
        if ElectronAppSingleton.shared.isFinishedLaunching() {
            if isPortOpen(port: ELECTRON_DEBUG_PORT) {
                print("\(path) started the debug WebSocket server".green)
                vulnerableStatus = true
                return true
            }
        }
        return false
    }
    
    return vulnerableStatus
}

func isPortOpen(port: UInt16) -> Bool {
    
    func swapBytesIfNeeded(port: in_port_t) -> in_port_t {
        let littleEndian = Int(OSHostByteOrder()) == OSLittleEndian
        return littleEndian ? _OSSwapInt16(port) : port
    }
    
    var serverAddress = sockaddr_in()
    serverAddress.sin_family = sa_family_t(AF_INET)
    serverAddress.sin_addr.s_addr = inet_addr("127.0.0.1")
    serverAddress.sin_port = swapBytesIfNeeded(port: in_port_t(port))
    let sock = socket(AF_INET, SOCK_STREAM, 0)
    
    let result = withUnsafePointer(to: &serverAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            connect(sock, $0, socklen_t(MemoryLayout<sockaddr_in>.stride))
        }
    }
    
    defer {
        close(sock)
    }
    
    if result != -1 {
        return true
    }
    
    return false
}
