//
//  inject.swift
//  electroniz3r
//
//  Created by Wojciech Reguła on 18/01/2023.
//

import Foundation

func canLoadWebSocketDebuggerUrl() -> Bool {
    
    var isWSURLSetSuccessfully = false
    
    guard let url = URL(string: "http://127.0.0.1:\(ELECTRON_DEBUG_PORT)/json/") else {
        print("Error: could not create a URL".red)
        return isWSURLSetSuccessfully
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print("Error: \(error?.localizedDescription ?? "No data")".red)
            return
        }
        
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        if let jsonDict = json as? [[String: Any]] {
            if let webSocketDebuggerUrlStringFromJSON = jsonDict[0]["webSocketDebuggerUrl"] as? String {
                print("The webSocketDebuggerUrl is: \(webSocketDebuggerUrlStringFromJSON)".green)
                ElectronAppSingleton.shared.webSocketDebuggerUrlString = webSocketDebuggerUrlStringFromJSON
            }
        }
    }
    task.resume()
    
    
    waitMaximally10Seconds {
        if ElectronAppSingleton.shared.webSocketDebuggerUrlString != "" {
            isWSURLSetSuccessfully = true
            return true
        }
        return false
    }
    
    
    return isWSURLSetSuccessfully
}
