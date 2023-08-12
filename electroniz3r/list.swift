import Foundation

func listElectronAppPaths() -> [String] {
    let fileManager = FileManager.default
    var electronFrameworkSubdirectories: [String] = []
    
    func searchForElectronFramework(path: String, depth: Int) {
        if depth > 6 {
            return
        }
        do {
            let subdirectories = try fileManager.contentsOfDirectory(atPath: path)
            for subdirectory in subdirectories {
                let subdirectoryPath = "\(path)/\(subdirectory)"
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: subdirectoryPath, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        if subdirectory == "Electron Framework.framework" {
                            electronFrameworkSubdirectories.append(subdirectoryPath)
                        } else if subdirectoryPath != "/Applications/Xcode.app" {
                            searchForElectronFramework(path: subdirectoryPath, depth: depth + 1)
                        }
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    var applicationsDirectoryPath: [String] = ["/Applications"]
    
    if NSUserName() != "root" {
        let userApplicationsDirectoryPath = NSString("~/Applications").expandingTildeInPath
        applicationsDirectoryPath.append(userApplicationsDirectoryPath)
    }
    
    applicationsDirectoryPath.forEach { path in
        searchForElectronFramework(path: path, depth: 0)
    }
    
    return electronFrameworkSubdirectories
}

func listElectronApps() -> [ElectronApp] {
    let electronAppPaths: [String] = listElectronAppPaths()
    var electronApps: [ElectronApp] = []
    
    electronAppPaths.forEach { electronAppPath in
    
        let electronFrameworkURL = URL(filePath: electronAppPath)
            
            let electronAppURL = electronFrameworkURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            
            if let bundle = Bundle(url: electronAppURL) {
                electronApps.append(ElectronApp(path: bundle.bundlePath, identifier: bundle.bundleIdentifier ?? ""))
            }
            
    }
    return electronApps
}

func prettyPrintElectronApps() {
    let electronApps = listElectronApps()
    
    print("╔══════════════════════════════════════════════════════════════════════════════════════════════════════╗")
    print("║    Bundle identifier                      │       Path                                               ║")
    print("╚──────────────────────────────────────────────────────────────────────────────────────────────────────╝")
    
    electronApps.forEach { electronApp in
        var offset: Int = 45 - electronApp.identifier.count
        
        if offset < 0 {
                offset = 2
        }
        
        print("\(electronApp.identifier)\(String(repeating: " ", count: offset))\(electronApp.path)")
    }
    
}
