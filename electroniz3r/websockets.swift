//
//  websockets.swift
//  electroniz3r
//
//  Created by Wojciech Reguła on 19/01/2023.
//

import Foundation

protocol WebSocketConnection {
    func send(text: String)
    func send(data: Data)
    func connect()
    func disconnect()
    var delegate: WebSocketConnectionDelegate? {
        get
        set
    }
}

protocol WebSocketConnectionDelegate {
    func onConnected(connection: WebSocketConnection)
    func onDisconnected(connection: WebSocketConnection, error: Error?)
    func onError(connection: WebSocketConnection, error: Error)
    func onMessage(connection: WebSocketConnection, text: String)
    func onMessage(connection: WebSocketConnection, data: Data)
}

class WebSocketTaskConnectionSingleton: NSObject, WebSocketConnection, URLSessionWebSocketDelegate {
    var delegate: WebSocketConnectionDelegate?
    var webSocketTask: URLSessionWebSocketTask!
    var urlSession: URLSession!
    let delegateQueue = OperationQueue()
    var didDebuggerRespond: Bool = false
    
    static var shared: WebSocketTaskConnectionSingleton = {
        let instance = WebSocketTaskConnectionSingleton()
        return instance
    }()
    
    
    private override init() {
        
        super.init()
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: delegateQueue)
        let url = URL(string: ElectronAppSingleton.shared.webSocketDebuggerUrlString)!
        webSocketTask = urlSession.webSocketTask(with: url)
        
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.delegate?.onConnected(connection: self)
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.delegate?.onDisconnected(connection: self, error: nil)
    }
    
    func connect() {
        webSocketTask.resume()
        
        listen()
    }
    
    func disconnect() {
        webSocketTask.cancel(with: .goingAway, reason: nil)
    }
    
    func listen()  {
        webSocketTask.receive { result in
            
            self.didDebuggerRespond = true
            
            switch result {
            case .failure(let error):
                self.delegate?.onError(connection: self, error: error)
            case .success(let message):
                switch message {
                case .string(let text):
                    self.delegate?.onMessage(connection: self, text: text)
                case .data(let data):
                    self.delegate?.onMessage(connection: self, data: data)
                    print(data)
                @unknown default:
                    fatalError()
                }
                
                self.listen()
            }
        }
    }
    
    func send(text: String) {
        webSocketTask.send(URLSessionWebSocketTask.Message.string(text)) { error in
            if let error = error {
                self.delegate?.onError(connection: self, error: error)
            }
        }
    }
    
    func send(data: Data) {
        webSocketTask.send(URLSessionWebSocketTask.Message.data(data)) { error in
            if let error = error {
                self.delegate?.onError(connection: self, error: error)
            }
        }
    }
    
    func executeCodeInElectronApp(code: String) {
        
        // sometimes NodeJS doesn't support atob. Changing it to Buffer...
        // let wrappedCode = "eval(atob('\(code.toBase64())'))"
        
        let wrappedCode = "eval(Buffer.from('\(code.toBase64())', 'base64').toString())"
        
        let cmd = "{\"id\":1337,\"method\":\"Runtime.evaluate\",\"params\":{\"expression\":\"\(wrappedCode)\",\"objectGroup\":\"console\",\"includeCommandLineAPI\":true,\"silent\":false,\"returnByValue\":false,\"generatePreview\":true,\"userGesture\":true,\"awaitPromise\":false,\"replMode\":true,\"allowUnsafeEvalBlockedByCSP\":false,\"executionContextId\":1}}"
        
        self.send(text: cmd)
    }
    
}
